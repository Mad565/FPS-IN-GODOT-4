extends StaticBody3D
var hp = 150
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if hp <=0:
		queue_free()
