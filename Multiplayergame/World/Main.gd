class_name main
extends Node2D

export(Array, PackedScene) var level

var random_level

# Called when the node enters the scene tree for the first time.
func _ready():
	print(Globals.num_players_alive)
	randomize()

	var random = level[int(rand_range(0, level.size()))]
	random_level = random.instance()

	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	Events.connect("player_died", self, "_on_player_death")

	print(random_level)
	add_child(random_level)


func _process(_delta):
	if Globals.num_players_alive == 1 and Globals.num_players > 1:
		change_level()


func _on_joy_connection_changed(device, connected):
	if connected:
		Globals.num_players = Input.get_connected_joypads().size()
		Globals.num_players_alive += 1

		random_level.add_player(device)
	else:
		random_level.remove_player(device)
		Globals.num_players_alive -= 1
		if Globals.num_players == 0:
			return


func change_level():
	remove_child(random_level)
	return


func _on_player_death():
	Globals.num_players_alive -= 1
	print(Globals.num_players_alive)

