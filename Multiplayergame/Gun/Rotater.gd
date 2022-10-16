class_name rotater
extends Node2D


var can_rotate = true
var controller = 0

const MAX_LENGTH = 1000000

onready var gun := $Gun

var rs_look = Vector2(0,0)
var deadzone = 0.3


func _physics_process(_delta):
	rslook()


func rslook():
	rs_look.y = Input.get_joy_axis(controller, JOY_AXIS_3)
	rs_look.x = Input.get_joy_axis(controller, JOY_AXIS_2)
	if rs_look.length() >= deadzone:
		rotation = rs_look.angle()

