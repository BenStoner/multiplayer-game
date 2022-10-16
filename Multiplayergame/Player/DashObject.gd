extends Node2D


func _process(_delta):
	modulate.a = lerp(modulate.a,0,0.2)
	if(modulate.a < 0.01):
		queue_free()
