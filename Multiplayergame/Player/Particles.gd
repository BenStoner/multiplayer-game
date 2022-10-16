extends Particles2D


func _process(_delta):
	if self.emitting == false:
		queue_free()
