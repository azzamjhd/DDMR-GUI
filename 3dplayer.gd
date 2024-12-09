extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	var input_dir = Input.get_axis("backward", "forward")
	var direction = Input.get_axis("right", "left")
	
	if direction or input_dir:
		var target_rotation = rotation.y + direction * 0.1
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.5)

		var input_vector = Vector3(0, 0, input_dir)
		velocity = input_vector.rotated(Vector3(0, 1, 0), rotation.y) * SPEED

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
