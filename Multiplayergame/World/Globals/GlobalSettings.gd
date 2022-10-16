extends Node


func toggle_fullscreen(value):
	OS.window_fullscreen = value


func toggle_Vsynce(value):
	OS.vsync_enabled = value


func update_master_vol(vol):
	AudioServer.set_bus_volume_db(0, vol)


func update_music_vol(vol):
	AudioServer.set_bus_volume_db(1, vol)


func update_SFX_vol(vol):
	AudioServer.set_bus_volume_db(2, vol)
