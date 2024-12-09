extends HBoxContainer
@onready var close = %close
@onready var close_2 = %close2
@onready var left_side = %leftSide
@onready var right_side = %rightSide
@onready var openButton = %open
@onready var open_2 = %open2

func _on_close_pressed():
	left_side.hide()
	openButton.show()

func _on_open_pressed():
	left_side.show()
	openButton.hide()

func _on_close_2_pressed():
	right_side.hide()
	open_2.show()

func _on_open_2_pressed():
	right_side.show()
	open_2.hide()
