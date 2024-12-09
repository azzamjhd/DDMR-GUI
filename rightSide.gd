extends PanelContainer
@onready var setting_bar = %setting
@onready var motor_tab = %Motor
@onready var odometry_tab = %Odometry

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if setting_bar.current_tab == 0:
		motor_tab.show()
		odometry_tab.hide()
	elif setting_bar.current_tab == 1:
		motor_tab.hide()
		odometry_tab.show()
