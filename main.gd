extends Control

var ws = SocketIOClient
var backendURL: String
var udp = PacketPeerUDP.new()
var connected = false
var lastInput = Vector2.ZERO

func _ready():
	#backendURL = "http://192.168.0.100:5000/socket.io"
	backendURL = "http://127.0.0.1:5000/socket.io"
	connect_to_backend()
	
	var err = udp.bind(5005, "*", 512)
	if err == OK:
		print("connected to UDP server")
		udp.put_packet("hello from godot!".to_utf8_buffer())
	else:
		print("failed to connect to UDP server: %s" % err)

func connect_to_backend():
	ws = SocketIOClient.new(backendURL, {"token":"MY_AUTH_TOKEN"})
	ws.on_engine_connected.connect(on_socket_ready)
	ws.on_connect.connect(on_socket_connect)
	ws.on_event.connect(on_socket_event)
	add_child(ws)

	connected = true
	
	await get_tree().create_timer(2).timeout
	ws.socketio_send("message", "hello from godot")

func sendCloseLoop(x: float, w: float):
	ws.socketio_send("closeLoop", {"x": x, "w": w})

func sendOpenLoop(pwmR: float, pwmL: float):
	ws.socketio_send("openLoop", {"pwmR": pwmR, "pwmL": pwmL})

func sendPidGains(kp: float, ki: float, kd: float):
	ws.socketio_send("pidGains", {"kp": kp, "ki": ki, "kd": kd})

func _exit_tree():
	ws.socketio_disconnect()

func on_socket_ready(_sid: String):
	ws.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend!")
	else:
		print("Socket connected")

func on_socket_event(event_name: String, payload: Variant, _name_space):
	print("Received ", event_name, " ", payload)
	if event_name == "response":
		%status.text = String(payload)
		%status.add_theme_color_override("font_color", Color(0, 1, 0))

func get_input():
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("left"):
		input_direction.x += 1
	if Input.is_action_pressed("right"):
		input_direction.x -= 1
	if Input.is_action_pressed("forward"):
		input_direction.y += 1
	if Input.is_action_pressed("backward"):
		input_direction.y -= 1
	%input.text = str(input_direction)
	%SetLinear.text = str(%LinearVar.value)
	%SetOmega.text = str(%OmegaVar.value)
	if input_direction != lastInput:
		lastInput = input_direction
		var x = input_direction.y * %LinearVar.value
		var w = input_direction.x * %OmegaVar.value
		sendCloseLoop(x, w)

	
	

func _process(delta):
	get_input()
	
	if %URLoptions.selected == 2:
		%URL.visible = true
	else:
		%URL.visible = false
	
	if udp.get_available_packet_count() > 0:
		var data = udp.get_packet().get_string_from_utf8()
		%textDisplay.text += data + "\n"
		%textDisplay.set_caret_line(%textDisplay.get_line_count())


func _on_start_pressed():
	ws.socketio_send("command", "start")

func _on_stop_pressed():
	ws.socketio_send("command", "stop")

func _on_reload_pressed():
	if connected:
		remove_child(ws)
		ws.queue_free()
		connected = false
		%status.text = "Disconnected"
		%status.add_theme_color_override("font_color", Color(1, 0, 0))
		%textDisplay.text = ""
	var selected = %URLoptions.selected
	if selected == 2:
		backendURL = "http://" + %URL.text + ":5000/socket.io"
	else:
		backendURL = "http://" + %URLoptions.get_item_text(selected) + ":5000/socket.io"
			
	connect_to_backend()

func _on_close_l_button_pressed():
	sendCloseLoop(%linear.value,%omega.value)

func _on_open_l_button_pressed():
	sendOpenLoop(%pwmR.value,%pwmL.value)

func _on_pid_gains_button_pressed():
	sendPidGains(%Kp.value,%Ki.value,%Kd.value)
