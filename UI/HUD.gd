extends CanvasLayer


export var INTERACT_RANGE = 96

onready var ag = get_parent()
onready var planet = ag.get_node("Planet")
onready var player = planet.get_node("Characters/Player")


func _ready():
	pass

func _process(delta):
	UpdateCameraLevel()
	UpdateTarget()
	
	UpdateToPlace()


func UpdateCameraLevel():
	$CameraLevel.text = "Camera Level: " + str(ag.currentLevel)

func UpdateTarget():
	var mouseLocal = planet.get_node("LevelMaps").to_local(ag.get_global_mouse_position())
	
	var tileId = -1
	var m = planet.get_node("LevelMaps/LevelMap0")
	var coords = m.world_to_map(mouseLocal)
	var l = -1
	if player.position.distance_to(mouseLocal) < INTERACT_RANGE:
		
		# find highest map at or below player level where targeted tile exists
		for i in range(ag.currentLevel):
			l = ag.currentLevel - i
			m = planet.get_node("LevelMaps/LevelMap" + str(l))
			tileId = m.get_cellv(coords)
			
			if tileId >= 0 and tileId != 12:  # 12 is Empty Collider
				break
		
	if tileId >= 0:  # if a valid tile is found
		ag.hoveredTile = coords
		ag.hoveredLevel = l
		
		var tileName = m.tile_set.tile_get_name(tileId)
		var displayName = Database.GetValue("Blocks", tileName, "displayName")
		var displayLevel = str(l - ag.currentLevel + 1)
		$TargetedBlock.text = "%s\nHeight: %s\nToolNeeded: %s" % [displayName, displayLevel, "TBD"]
		
		if Database.GetValue("Blocks", tileName, "toolNeeded") == player.wielding and int(displayLevel) in [1, 0]:
			$TargetedBlock.text += "\nCAN " + Database.GetValue("Tools", player.wielding, "verb").to_upper()
		if int(displayLevel) in [0, -1]:
			$TargetedBlock.text += "\nCAN PLACE"
		
		$TargetedBlock.show()
		$ToPlace.show()
		
		planet.get_node("LevelMaps/TileSelector").position = m.map_to_world(coords)
		planet.get_node("LevelMaps/TileSelector").show()
	
	else:
		$TargetedBlock.hide()
		$ToPlace.hide()
		planet.get_node("LevelMaps/TileSelector").hide()
		ag.hoveredTile = null
		ag.hoveredLevel = null

func UpdateToPlace():
	if AnyPanelsActive():
		$TargetedBlock.hide()
		$ToPlace.hide()
	
	elif player.toPlace:
		var q = player.inventory.Get(player.toPlaceItem)
		$ToPlace.text = "TO PLACE: %d x " % [q]
		
		$ToPlace/TextureRect.texture = planet.GetIconTexture(player.toPlace)
		$ToPlace/TextureRect.rect_rotation = Constants.dirToRot[player.toPlaceRot]
		$ToPlace.show()
		$TargetedBlock.show()
		
	else:
		$ToPlace.text = "TO PLACE: N/A"
		$ToPlace/TextureRect.texture = null
		$ToPlace.show()
		$TargetedBlock.show()

func AnyPanelsActive():
	for p in [$ToolSelect, $BuildMenu, $PlayerPanels, $ObjectInteraction]:
		if p.visible:
			return true
	
	return false
