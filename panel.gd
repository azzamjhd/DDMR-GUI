extends VBoxContainer
@onready var left_side = %leftSide
@onready var right_side = %rightSide
@onready var bottomPanel = %bottom
@onready var openButton = %open
@onready var close = %close
@onready var close_2 = %close2
@onready var open_2 = %open2
@onready var close_3 = %close3
@onready var open_3 = %open3

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

func _on_close_3_pressed():
	bottomPanel.hide()
	open_3.show()


func _on_open_3_pressed():
	bottomPanel.show()
	open_3.hide()
