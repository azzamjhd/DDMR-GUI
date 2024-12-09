extends HFlowContainer

@export var X_value: float
@export var Y_value: float
@export var Theta_value: float
@export var cmd: Vector2

@onready var x_label = $HBoxContainer/x_label
@onready var y_label = $HBoxContainer2/y_label
@onready var theta_label = $HBoxContainer3/theta_label
@onready var linear_cmd = $HBoxContainer4/linear_cmd
@onready var omega_cmd = $HBoxContainer4/omega_cmd

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	x_label.text = str(X_value)
	y_label.text = str(Y_value)
	theta_label.text = str(Theta_value)
	linear_cmd.text = str(cmd.x)
	omega_cmd.text = str(cmd.y)
