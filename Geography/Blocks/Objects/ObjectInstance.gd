extends Node2D


export var object = ""
var inventory = null


func _ready():
	if get_node("Inventory"):
		inventory = get_node("Inventory")
