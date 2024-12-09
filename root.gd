extends Node

var ws = SocketIOClient
var backendURL: String
var udp = PacketPeerUDP.new()
var connected = false
var udp_thread = null
var mutex = Mutex.new()
var packet_queue = []
var lastInput = Vector2.ZERO
var input_button: Vector2

@export var player: CharacterBody2D

@onready var serial_content = %Serial/TextEdit

@onready var connect_btn = %connectBtn
@onready var disconnect_btn = %disconnectBtn
@onready var not_connected_icon = %not_connected
@onready var connected_icon = %connected
@onready var ip_input = %ip_input
@onready var port_input = %port_input
@onready var goal_x = %goal_x
@onready var goal_y = %goal_y
@onready var goal_t = %goal_t

## button input
@onready var forward_btn = %forwardBtn
@onready var left_btn = %leftBtn
@onready var back_btn = %backBtn
@onready var right_btn = %rightBtn
@onready var goal_send_btn = %goal_send_btn

## contains x, y, and theta GUI elements
@onready var odometry = %odometry
## settings for manual control
@onready var max_linear = %max_linear
@onready var max_omega = %max_omega
@onready var p_setting = %P_setting
@onready var i_setting = %I_setting
@onready var d_setting = %D_setting

# Status
@onready var sensor_left = %sensor_left
@onready var sensor_front = %sensor_front
@onready var sensor_right = %sensor_right
@onready var speed_left = %speed_left
@onready var speed_right = %speed_right

var closeLoop = "c"
var pidGains = "p"
var getPidGains = "g"
var getStatus = "s"
var reset = "r"
var goalSet = "t"

var data_size = 38

## This function for connecting websocket
func connect_to_backend():
	ws = SocketIOClient.new(backendURL, {"token":"MY_AUTH_TOKEN"})
	ws.on_engine_connected.connect(on_socket_ready)
	ws.on_connect.connect(on_socket_connect)
	ws.on_event.connect(on_socket_event)
	add_child(ws)

## This is the function that will be called when the socket connects to the backend
func on_socket_ready(_sid: String):
	ws.socketio_connect()

## This is the function that will be called when the socket connects to the backend
func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		print("Failed to connect to backend!")
		remove_child(ws)
		ws.queue_free()
	else:
		print("Socket connected")
		connected = true
		#await get_tree().create_timer(1).timeout
		#ws.socketio_send("message", "hello from godot")

## This is the function that will be called when the socket receives an event
func on_socket_event(event_name: String, payload: Variant, _name_space):
	print("Received ", event_name, " ", payload)
	if event_name == "json":
		var json = JSON.new()
		var error = json.parse(payload)
		if error != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", payload, " at line ", json.get_error_line())
			return
		var kp = json.get_data().get("kp")
		var ki = json.get_data().get("ki")
		var kd = json.get_data().get("kd")

		## update the PID gains
		p_setting.value = kp
		i_setting.value = ki
		d_setting.value = kd

		print("Received PID gains: ", kp, ki, kd)
	elif event_name == "status":
		var status = JSON.new()
		var error = status.parse(payload)
		if error != OK:
			print("JSON Parse Error: ", status.get_error_message(), " in ", payload, " at line ", status.get_error_line())
			return
		var pose = status.get_data().get("pose")
		if pose and pose.size() == 3:
			player.global_position = Vector2(pose[0]*260, -pose[1]*260)
			player.rotation = -pose[2]
		else:
			print("Invalid pose data: ", pose)
		
		var sensor = status.get_data().get("sensor")
		if sensor and sensor.size() == 3:
			sensor_left.value = sensor[0]
			sensor_front.value = sensor[1]
			sensor_right.value = sensor[2]
		else:
			print("Invalid sensor data: ", sensor)

		var speed = status.get_data().get("speed")
		if speed and speed.size() == 2:
			speed_left.value = speed[0]
			speed_right.value = speed[1]
		else:
			print("Invalid speed data: ", speed)


func get_input():
	if Input.is_action_pressed("reset"):
		sendSerialCommand(reset)

	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("right", "left")
	input_direction.y = Input.get_axis("backward", "forward")

	if input_direction == Vector2.ZERO:
		input_direction = input_button

	if input_direction != lastInput:
		lastInput = input_direction
		var cmd = Vector2()
		cmd.x = input_direction.y * max_linear.value * 1000
		cmd.y = input_direction.x * max_omega.value * 1000
		odometry.cmd = cmd
		sendSerialCommand(closeLoop, [cmd.x, cmd.y])

## Built-in functions
func _exit_tree():
	if udp_thread:
		udp_thread.wait_to_finish()
		udp_thread = null
	udp.close()

func _ready():
	var error = udp.bind(5005, "*", 512)
	if error == OK:
		print("connected to UDP server")
		udp.put_packet("hello from godot!".to_utf8_buffer())
		serial_content.text = ""
		udp_thread = Thread.new()
		udp_thread.start(_udp_process)
	else:
		print("failed to connect to UDP server: %s" % error)

func _process(_delta):
	get_input()

	if connected:
		connected_icon.show()
		not_connected_icon.hide()
		connect_btn.hide()
		disconnect_btn.show()
	else:
		connected_icon.hide()
		not_connected_icon.show()
		connect_btn.show()
		disconnect_btn.hide()

	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var packet_text = packet.get_string_from_utf8()
		
		serial_content.text += packet_text + "\n"

		var json = JSON.new()
		var error = json.parse(packet_text)
		if error != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", packet_text, " at line ", json.get_error_line())
			return
		
		var pose = json.get_data().get("pose")
		if pose and pose.size() == 3:
			player.global_position = Vector2(pose[0]*260, pose[1]*260)
			player.rotation = pose[2]
		else:
			print("Invalid pose data: ", pose)
		
		var sensor = json.get_data().get("sensor")
		if sensor and sensor.size() == 3:
			sensor_left.value = sensor[0]
			sensor_front.value = sensor[1]
			sensor_right.value = sensor[2]
		else:
			print("Invalid sensor data: ", sensor)

		var speed = json.get_data().get("speed")
		if speed and speed.size() == 2:
			speed_left.value = speed[0]
			speed_right.value = speed[1]
		else:
			print("Invalid speed data: ", speed)

	

func _udp_process():
	# while true:
	if udp.get_available_packet_count() > 0:
		mutex.lock()
		var packet = udp.get_packet()
		var packet_text = packet.get_string_from_utf8()
		call_deferred("_update_serial_content", packet_text)

		var json = JSON.new()
		var error = json.parse(packet_text)
		if error != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", packet_text, " at line ", json.get_error_line())
			return
		
		var pose = json.get_data().get("pose")
		if pose and pose.size() == 3:
			call_deferred("_update_player", pose)
		else:
			print("Invalid pose data: ", pose)

		mutex.unlock()
	else:
		OS.delay_msec(1)  # Small delay to prevent high CPU usage


func _update_serial_content(packet_text):
	serial_content.text += packet_text + "\n"

func _update_player(pose):
	player.global_position = Vector2(pose[0], pose[1])
	print("Received pose: ", pose)
	player.rotation = pose[2]

## WebSocket send functions
func sendSerialCommand(prefix: String, values: Array = []):
	var data = {"prefix": prefix}
	if values.size() > 0:
		data["values"] = values
	ws.socketio_send("serial", data)
	print("Sending serial command: ", data)


## Signals functions

func _on_connect_btn_pressed():
	if ip_input.text == "" or port_input.text == "":
		push_error("Please enter IP and Port")
		return
	backendURL = "http://" + ip_input.text + ":" + port_input.text + "/socket.io"
	connect_to_backend()


func _on_disconnect_btn_pressed():
	ws.socketio_disconnect()
	remove_child(ws)
	ws.queue_free()
	connected = false

func _on_forward_btn_button_up():
	input_button.y += 1

func _on_forward_btn_button_down():
	input_button.y -= 1
	sendSerialCommand(getPidGains)

func _on_back_btn_button_up():
	input_button.y -= 1

func _on_back_btn_button_down():
	input_button.y += 1

func _on_left_btn_button_up():
	input_button.x += 1

func _on_left_btn_button_down():
	input_button.x -= 1

func _on_right_btn_button_up():
	input_button.x -= 1

func _on_right_btn_button_down():
	input_button.x += 1

## send pid gains to the backend
func _on_pid_gains_btn_pressed():
	print("Sending PID gains")
	var p = round(p_setting.value * 1000)
	var i = round(i_setting.value * 1000)
	var d = round(d_setting.value * 1000)
	sendSerialCommand(pidGains, [p, i, d])

func _on_goal_send_btn_pressed():
	var x = round(goal_x.value * 1000)
	var y = round(goal_y.value * 1000)
	if goal_t.value == 0:
		sendSerialCommand(goalSet, [int(x), int(y)])
	else:
		var theta = goal_t.value # -180 to 180
		sendSerialCommand(goalSet, [int(x), int(y), int(theta)])
