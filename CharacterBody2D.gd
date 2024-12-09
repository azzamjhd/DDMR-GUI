extends CharacterBody2D

@export var SPEED = 50

func _physics_process(delta):
	var forward = Input.get_axis("backward", "forward")
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		var target_rotation = rotation + direction * 0.1
		#rotation = lerp_angle(rotation, target_rotation, 0.5)
	
	var input_vector = Vector2(0, forward)
	velocity = input_vector.rotated(rotation) * SPEED
	#move_and_slide()


func _on_close_pressed():
	pass # Replace with function body.
