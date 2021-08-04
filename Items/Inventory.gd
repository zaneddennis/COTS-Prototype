extends Node


export var data = {}
export var dimensions = Vector2(0, 0)


func _ready():
	pass


func AttemptAdd(i, q):
	if i in data:
		data[i] += q
	
	elif len(data) < dimensions.x * dimensions.y:
		data[i] = q
	
	else:
		return false
	
	return true

func AttemptRemove(i, q):
	if i in data:
		if data[i] > q:
			data[i] -= q
		elif data[i] == q:
			data.erase(i)
		else:
			return false
	
	else:
		return false
	
	return true


func Get(i):
	return data[i]

func Names():
	return data.keys()

func Contains(i):
	return i in data
