extends Node
@onready var player = %player
@onready var coordinate = %coordinate
@onready var camera = %player/Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	coordinate.text = str(player.position/260)
	pass


func _on_open_3_pressed():
	camera.offset.y = 100

func _on_close_3_pressed():
	camera.offset.y = 0
