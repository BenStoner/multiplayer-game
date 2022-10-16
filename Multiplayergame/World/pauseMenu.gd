extends Popup

var is_paused = false

onready var resume := $"%Resume"
onready var options := $"%Options"
onready var quit := $"%Quit"

func _process(_delta):
	if Input.is_action_just_pressed("options") and is_paused == false:
		pause()
	elif Input.is_action_just_pressed("options") and is_paused == true:
		unpause()

	if Input.is_action_just_pressed("o"):
		unpause()


func pause():
	self.popup()
	get_tree().paused = true
	is_paused = true
	resume.grab_focus()

func unpause():
	self.hide()
	get_tree().paused = false
	is_paused = false


func _on_Resume_pressed():
	unpause()


func _on_Options_pressed():
	$OptionsMenu.popup()


func _on_Quit_pressed():
	Globals.goto_scene("res://World/Levels/MainMenu/MainMenu.tscn")
