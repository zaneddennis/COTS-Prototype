extends Timer


func _ready():
	pass

func _process(delta):
	if not is_stopped():
		get_parent().value += get_parent().max_value * (delta/wait_time)
