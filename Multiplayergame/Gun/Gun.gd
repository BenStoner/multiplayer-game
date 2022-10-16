extends Node

export var LineBullet: PackedScene

export var input_shoot: String = "shoot"
export var fire_rate := 60

export(Array, Texture) var gun_textures

var deviation_angle = PI * 0.01
var can_shoot 
var is_shooting = false

onready var bullet_spawn := $Position2D
onready var walldetection := $WallDetection


func _physics_process(delta):
	if walldetection.is_colliding():
		can_shoot = false
	elif not walldetection.is_colliding():
		can_shoot = true

	if is_shooting == true:
		$AudioStreamPlayer2D.play()
	elif is_shooting == false:
		$AudioStreamPlayer2D.stop()

	if Input.is_action_pressed(input_shoot) and can_shoot == true:
		var bullets_to_spawn := round(fire_rate * delta)
		for i in bullets_to_spawn:
			is_shooting = true
			var new_bullet = LineBullet.instance()
			new_bullet.global_position = bullet_spawn.global_position
			new_bullet.global_rotation = bullet_spawn.global_rotation 
			new_bullet.rotation += rand_range(-deviation_angle,
			deviation_angle)
			new_bullet.set_as_toplevel(true)
			add_child(new_bullet)
	else:
		is_shooting = false



