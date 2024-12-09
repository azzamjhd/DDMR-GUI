extends VBoxContainer

@export var name_text: String
@export var value: float
@export var min_value: float
@export var max_value: float
@export var suffix: String

@onready var range_label = $range
@onready var value_label = $value
@onready var name_label = $Panel/Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value_label.value = value
	value_label.suffix = suffix
	
	name_label.text = name_text
	
	range_label.min_value = min_value
	range_label.max_value = max_value
	range_label.value = value
