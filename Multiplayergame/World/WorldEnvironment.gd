extends WorldEnvironment


func _ready():
	GlobalSettings.connect("bloom_change", self, "_update_bloom")


func _update_bloom(bloom):
	print(environment.glow_intensity)
	environment.glow_bloom = bloom
	if environment.glow_bloom >= 1:
		environment.glow_enabled = true
