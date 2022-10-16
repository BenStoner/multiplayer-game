extends Control

onready var fight := $"%Fight"
onready var options := $"%Options"
onready var options_menu := $OptionsMenu
onready var quit := $"%Quit"

var tween = Tween.new()

func _ready():
	fight.grab_focus()
	$AnimationPlayer.play("bounce")


func _on_Fight_pressed():
	Globals.goto_scene("res://World/Main.tscn")


func _on_Options_pressed():
	options_menu.popup()


func _on_Quit_pressed():
	get_tree().quit()
