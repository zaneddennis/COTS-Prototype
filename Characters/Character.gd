extends KinematicBody2D


var prevCoords = Vector2(-1, -1)


var velocity = Vector2(0, 0)
var speed = 128


func _ready():
	pass


func HandleMovement():
	velocity = velocity.rotated(rotation)
	
	move_and_slide(velocity*speed)
	
	# get current Tile
	var planet = get_parent().get_parent()
	var headLevel = planet.get_parent().currentLevel
	var footLevel = headLevel - 1
	var tmHead = planet.get_node("LevelMaps/LevelMap" + str(headLevel))
	var tmFoot = planet.get_node("LevelMaps/LevelMap" + str(footLevel))
	var coords = tmHead.world_to_map(global_position + Vector2(0, 16))
	
	# if new, check for Triggers
	if coords != prevCoords:
		var cellHead = tmHead.get_cellv(coords)
		var cellFoot = tmFoot.get_cellv(coords)
		var blockHead = Database.GetItem("Blocks", tmHead.tile_set.tile_get_name(cellHead))
		var blockFoot = Database.GetItem("Blocks", tmFoot.tile_set.tile_get_name(cellFoot))
	
		# Ramps
		# check head level and foot level for Ramp
		if blockHead and blockHead.isRamp:
			print("Ramp Up from %s to %s" % [headLevel, headLevel+1])
			SetLevel(headLevel, headLevel + 1)
		elif blockFoot and blockFoot.isRamp:
			print("Ramp Down from %s to %s" % [headLevel, footLevel])
			SetLevel(headLevel, footLevel)
			
		
		prevCoords = coords

func SetLevel(cl, l):
	
	set_collision_layer_bit(cl-1, false)
	set_collision_mask_bit(cl-1, false)
	
	get_parent().get_parent().get_parent().currentLevel = l
	
	set_collision_layer_bit(l-1, true)
	set_collision_mask_bit(l-1, true)
	
	get_parent().get_parent().SetLevel(l)
