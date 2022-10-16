extends Popup


func _ready():
	AudioServer.set_bus_volume_db(0, 24)
	AudioServer.set_bus_volume_db(1, 0)
	AudioServer.set_bus_volume_db(2, 10)
	$VBoxContainer2/MasterVol.value = 24
	$VBoxContainer2/MusicVol.value = 0
	$VBoxContainer2/SFXVol.value = 10


#func _process(delta):
#	if OS.window_fullscreen == true:
#		$VBoxContainer/Fullscreen.set_pressed(true)


func _on_Fullscreen_toggled(button_pressed):
	GlobalSettings.toggle_fullscreen(button_pressed)


func _on_Vsync_toggled(button_pressed):
	GlobalSettings.toggle_Vsynce(button_pressed)


func _on_MasterVol_value_changed(value):
	GlobalSettings.update_master_vol(value)


func _on_MusicVol_value_changed(value):
	GlobalSettings.update_music_vol(value)


func _on_SFXVol_value_changed(value):
	GlobalSettings.update_SFX_vol(value)


func _on_Back_pressed():
	self.hide()
