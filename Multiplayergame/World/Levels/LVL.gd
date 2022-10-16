class_name LVL
extends Node2D

export var target_multi_players: bool

var camera_instance = preload("res://World/Camera/Camera2D.tscn")
var player_instance = preload("res://Player/player.tscn")

var players: Array = []

var spawn_poses = rand_range(10, 0)

var new_camera = camera_instance.instance()


func _init():
	for player_index in range(Globals.num_players):
		add_player(player_index)


func _ready():
	add_child(new_camera)
	new_camera.target_multi_players = target_multi_players


func add_player(player_index):
	players.append(player_instance.instance())
	add_child(players[player_index])

	var player = players[-1]
	
	player.player_num = player_index

	new_camera.add_target(players[player_index])

# ERROR WHEN FIRST CONNECTED CONTROLLER DISCONNECTS THEN SECOND ONE DISCONNECTS ERROR OCCURS
	
func remove_player(player_index):
	if players.size() == 0:
		return
	elif players.size() > 0:
		Globals.num_players -= 1
		remove_child(players[player_index])
		players.remove(player_index)

		if players.size() > 1:
			new_camera.remove_target(players[player_index])

func instance_player():
	add_child(player_instance.instance())
