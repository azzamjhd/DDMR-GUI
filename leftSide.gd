extends PanelContainer
@onready var network_tab_bar = %NetworkTabBar
@onready var ip_tab = %IP
@onready var serial_tab = %Serial

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if network_tab_bar.current_tab == 0:
		ip_tab.show()
		serial_tab.hide()
	elif  network_tab_bar.current_tab == 1:
		ip_tab.hide()
		serial_tab.show()
