class_name laserBullet
extends Node2D

export var stats: Resource

var direction := Vector2.ZERO

onready var timer := $Timer
onready var hitbox := $Hitbox
onready var sprite := $Sprite
onready var impact_detector_top := $Raycasts/ImpactsDetectorTop
onready var impact_detector_middle := $Raycasts/ImpactsDetectorMiddle
onready var impact_detector_buttom := $Raycasts/ImpactsDetectorButtom
onready var anim := $AnimationPlayer


func _ready():
	hitbox.damage = stats.damage

	sprite.visible = true
	set_as_toplevel(true)

	look_at(position + direction)

	timer.connect("timeout", self, "queue_free")
	timer.start(stats.lifetime)


func _physics_process(delta: float) -> void:
	position += transform.x * stats.speed * delta

	if impact_detector_top.is_colliding() or impact_detector_middle.is_colliding() or impact_detector_buttom.is_colliding():
		anim.play("hit")
