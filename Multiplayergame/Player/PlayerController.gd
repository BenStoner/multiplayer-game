class_name playerCharacter
extends KinematicBody2D

# Inputs
export var input_Lstick_left : String = "move_left0"
export var input_Lstick_right : String = "move_right0"
export var input_Lstick_down : String = "move_down0"
export var input_Lstick_up : String = "move_up0"
export var input_jump : String = "jump0"
export var input_dash : String = "dash0"

export var max_jump_height = 150 setget set_max_jump_height
export var min_jump_height = 40 setget set_min_jump_height
export var double_jump_height = 100 setget set_double_jump_height
export var jump_duration = 0.3 setget set_jump_duration

export var falling_gravity_multiplier = 1.5
export var fast_falling_gravity_multiplier = 2.5

export var max_jump_amount = 1

export var max_acceleration = 4000
export var friction = 8

export var can_hold_jump : bool = false

export var coyote_time : float = 0.1
export var jump_buffer : float = 0.1 

export var wall_slide_speed : float = .2
export var can_wall_slide : bool = true

export var max_health : int = 100
export var health = 100

export var dash_hangtime = 0.1
export var dash_speed : float  = 450
export var dash_length : float = 0.1
export var dash_object = preload("res://Player/dash_object.tscn")

export(Array, Texture) var player_textures

# Not used
var max_speed = 100
var acceleration_time = 10

# These will be calcualted automatically
var default_gravity : float
var jump_velocity : float
var double_jump_velocity : float
# Multiplies the gravity by this when we release jump
var release_gravity_multiplier : float

var jumps_left : int
var holding_jump := false

var is_in_air := false
var is_colliding_with_wall : bool
var can_take_damage : bool

var is_dashing := false
var can_dash := true
var dash_direction : Vector2

var dust_particles = preload("res://Player/Dust.tscn")
var death_particles = preload("res://Player/DeathParticles.tscn")

# Velocity a acceleration 
var vel := Vector2.ZERO
var acc = Vector2()

var device_num
var player_num

onready var coyote_timer = Timer.new()
onready var jump_buffer_timer = Timer.new()
onready var dash_timer = Timer.new()
onready var dash_hang_time = Timer.new()

onready var anim := $AnimationPlayer
onready var sprite := $Sprite
onready var gun := $GunHolder/Gun
onready var right_wall_detection := $Raycasts/RightWallCollide
onready var left_wall_detection := $Raycasts/LeftWallCollide


func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
	jump_velocity, min_jump_height, default_gravity)


func _ready(): 
	add_child(coyote_timer)
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true

	add_child(jump_buffer_timer)
	jump_buffer_timer.wait_time = jump_buffer
	jump_buffer_timer.one_shot = true

	dash_timer.connect("timeout", self, "dash_timer_timeout")
	add_child(dash_timer)
	dash_timer.wait_time = dash_length
	dash_timer.one_shot = true

	add_child(dash_hang_time)
	dash_hang_time.wait_time = dash_hangtime
	dash_hang_time.one_shot = true


func _physics_process(delta):
	handle_dash(delta)
	handle_inputs()
	handle_wall_slide()
	get_health()

	anim.play("Bounce")

	is_colliding_with_wall = right_wall_detection.is_colliding() or left_wall_detection.is_colliding()
	is_in_air = not is_on_floor()

	acc.x = 0

	if is_on_floor():
		coyote_timer.start()
		can_dash = true
	if not coyote_timer.is_stopped():
		jumps_left = max_jump_amount

	if not dash_hang_time.is_stopped():
		vel.y = 0

	if Input.is_action_pressed(input_Lstick_left):
		acc.x = -max_acceleration
		sprite.flip_h = true
	if Input.is_action_pressed(input_Lstick_right):
		sprite.flip_h = false
		acc.x = max_acceleration

	if can_hold_jump:
		if Input.is_action_pressed(input_jump):
			if is_on_floor():
				jump()

	if not can_hold_jump:
		if not jump_buffer_timer.is_stopped() and is_on_floor():
			jump()

	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		jump_buffer_timer.start()

		if not is_on_floor():
			jump()

	if Input.is_action_just_released(input_jump):
		holding_jump = false

	var gravity = default_gravity

	if Input.is_action_pressed(input_Lstick_down) and not is_on_floor(): # Fast fall
		gravity *= fast_falling_gravity_multiplier

	if vel.y > 0 and is_in_air: # If we are falling
		gravity *= falling_gravity_multiplier

	if not holding_jump and vel.y < 0: # If we released jump and are still rising
		if not jumps_left < max_jump_amount - 1: # Always jump to max height when we are using a double jump
			gravity *= release_gravity_multiplier # Multiply the gravity so we have a lower jump

	acc.y = -gravity
	vel.x *= 1 / (1 + (delta * friction))

	vel += acc * delta

	if is_dashing:
		vel = move_and_slide(dash_direction, Vector2.UP)
		vel.y = 0
		vel.x = 0
	else:
		vel = move_and_slide(vel, Vector2.UP)


func dash_timer_timeout():
	is_dashing = false
	dash_hang_time.start()


func get_controller_direction():
	if Input.get_action_strength(input_Lstick_down) > 0.6:
		return true
	if Input.get_action_strength(input_Lstick_up) > 0.6:
		return true
	if Input.get_action_strength(input_Lstick_left) > 0.6:
		return true
	if Input.get_action_strength(input_Lstick_right) > 0.6:
		return true

	return false


func get_direction_from_input():
	var move_dir = Vector2()
	var controller = get_controller_direction()

	if controller:
		move_dir.x = -Input.get_action_strength(input_Lstick_left) + Input.get_action_strength(input_Lstick_right)
		move_dir.y = Input.get_action_strength(input_Lstick_down) - Input.get_action_strength(input_Lstick_up)

		move_dir = move_dir.limit_length(1)

	# Check if not moving/nothing pressed
	if(move_dir == Vector2(0, 0)):
		if sprite.flip_h == true:
			move_dir.x = -1
		else:
			move_dir.x = 1

	return move_dir * dash_speed


func handle_wall_slide():
	if can_wall_slide and is_in_air and is_colliding_with_wall:
		if Input.is_action_pressed(input_Lstick_left) or Input.is_action_pressed(input_Lstick_right) and can_wall_slide == true:
			vel.y = wall_slide_speed

			if sprite.flip_h == false:
				sprite.flip_h = true
			elif sprite.flip_h == true:
				sprite.flip_h = false

		else:
			return 


func handle_dash(_delta):
	if Input.is_action_just_pressed(input_dash) and can_dash:
		is_dashing = true
		can_dash = false

		dash_direction = get_direction_from_input()
		dash_timer.start(dash_length)

	if(is_dashing):
		var dash_node = dash_object.instance()
		dash_node.texture = sprite.texture
		dash_node.hframes = 2
		dash_node.frame = sprite.frame
		dash_node.flip_h = sprite.flip_h
		dash_node.global_position = global_position
		get_parent().add_child(dash_node)

		if is_on_wall():
			is_dashing = false

		pass


func handle_inputs():
	if player_num == 0:
		input_Lstick_down = "move_down0"
		input_Lstick_left = "move_left0"
		input_Lstick_right = "move_right0"
		input_Lstick_up = "move_up0"
		input_dash = "dash0"
		input_jump = "jump0"
		$GunHolder/Gun.input_shoot = "shoot0"
		$GunHolder.controller = 0
		$GunHolder/Gun/Sprite.texture = $GunHolder/Gun.gun_textures[0]
		sprite.texture = player_textures[0]
	elif player_num == 1:
		input_Lstick_down = "move_down1"
		input_Lstick_left = "move_left1"
		input_Lstick_right = "move_right1"
		input_Lstick_up = "move_up1"
		input_dash = "dash1"
		input_jump = "jump1"
		$GunHolder/Gun.input_shoot = "shoot1"
		$GunHolder.controller = 1
		$GunHolder/Gun/Sprite.texture = $GunHolder/Gun.gun_textures[1]
		sprite.texture = player_textures[1]
	elif player_num == 2:
		input_Lstick_down = "move_down2"
		input_Lstick_left = "move_left2"
		input_Lstick_right = "move_right2"
		input_Lstick_up = "move_up2"
		input_dash = "dash2"
		input_jump = "jump2"
		$GunHolder/Gun.input_shoot = "shoot2"
		$GunHolder.controller = 2
		$GunHolder/Gun/Sprite.texture = $GunHolder/Gun.gun_textures[2]
		sprite.texture = player_textures[2]
	elif player_num == 3:
		input_Lstick_down = "move_down3"
		input_Lstick_left = "move_left3"
		input_Lstick_right = "move_right3"
		input_Lstick_up = "move_up3"
		input_dash = "dash3"
		input_jump = "jump3"
		$GunHolder/Gun.input_shoot = "shoot3"
		$GunHolder.controller = 3
		$GunHolder/Gun/Sprite.texture = $GunHolder/Gun.gun_textures[3]
		sprite.texture = player_textures[3]


func take_damage(damage: int) -> void:
	print(health)
	health -= damage
#	if is_dashing == false and is_in_air:

var death_instance = death_particles.instance()

func get_health():
	if health == 0:
		kill_player()


func kill_player():
	Events.emit_signal("player_died")
	death_instance.global_position = self.global_position
	death_instance.emitting = true
	get_tree().get_root().add_child(death_instance)
	queue_free()


func calculate_gravity(p_max_jump_height, p_jump_duration):
	return (-2 *p_max_jump_height) / pow(p_jump_duration, 2)


func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / (p_jump_duration)


func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	return sqrt(-2 * p_gravity * p_max_jump_height)


func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	var release_gravity = 0 - pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity


func calculate_friction(time_to_max):
	return 1 - (2.30259 / time_to_max)


func calculate_speed(p_max_speed, p_friction):
	return (p_max_speed / p_friction) - p_max_speed


func jump():
	var dust_instance = dust_particles.instance()
	if jumps_left == max_jump_amount and coyote_timer.is_stopped():
		jumps_left -= 1

	if jumps_left > 0:
		if jumps_left < max_jump_amount:
			vel.y = -double_jump_velocity

			dust_instance.global_position = $Position2D.global_position
			dust_instance.emitting = true
			get_tree().get_root().add_child(dust_instance)

		else:
			vel.y = -jump_velocity

			dust_instance.global_position = $Position2D.global_position
			dust_instance.emitting = true
			get_tree().get_root().add_child(dust_instance)
		jumps_left -= 1


	coyote_timer.stop()


func set_max_jump_height(value):
	max_jump_height = value

	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)


func set_jump_duration(value):
	jump_duration = value

	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)


func set_min_jump_height(value):
	min_jump_height = value
	release_gravity_multiplier = calculate_release_gravity_multiplier(
		jump_velocity, min_jump_height, default_gravity)


func set_double_jump_height(value):
	double_jump_height = value
	double_jump_velocity = calculate_jump_velocity2(double_jump_height, default_gravity)
