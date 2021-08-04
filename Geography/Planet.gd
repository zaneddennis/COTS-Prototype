extends Node2D


onready var ag = get_parent()
onready var player = get_node("Characters/Player")
onready var tileSet = $LevelMaps/LevelMap0.tile_set

var interactingLevel = null
var interactingTile = null


func _ready():
	pass

func _process(delta):
	pass


func SetLevel(l):
	for i in range(4):
		var lNode = get_node("LevelMaps/LevelMap" + str(i))
		
		if i <= l:
			lNode.show()
		else:
			lNode.hide()


func AttemptLCInteract():
	var level = ag.hoveredLevel
	var coords = ag.hoveredTile
	var t = player.wielding
	
	var tileType = get_node("LevelMaps/LevelMap" + str(level)).get_cellv(coords)
	tileType = get_node("LevelMaps/LevelMap" + str(level)).tile_set.tile_get_name(tileType)
	
	print("Player attempts a [LC] Interact at %s %s [%s] using %s" % [level, coords, tileType, t])
	print(level - ag.currentLevel)
	var tNeeded = Database.GetValue("Blocks", tileType, "toolNeeded")
	if t == tNeeded and (level - ag.currentLevel) in [0, -1]:
		var verb = Database.GetValue("Tools", t, "verb")
		print("Interaction successful! Player %ss." % [verb])
		
		interactingLevel = level
		interactingTile = coords
		
		var iTime = 1.6  # todo: make this a calculation of a database value for each Block type and a tool's value (for when I have multiple Tools for each ToolType)
		player.Swing(iTime)

# 
func CompleteLCInteract():
	var tm = get_node("LevelMaps/LevelMap" + str(interactingLevel))
	var block = Database.GetItem("Blocks", tm.tile_set.tile_get_name(tm.get_cellv(interactingTile)))
	var item = block.gives
	
	# remove tile from world
	tm.set_cellv(interactingTile, -1)
	tm.update_bitmask_area(interactingTile)
	UpdateEmptyColliders(interactingLevel, interactingTile)
	print("Harvesting %s tile" % block.name)
	
	# add to player inventory
	player.inventory.AttemptAdd(item, 1)
	
	interactingLevel = null
	interactingTile = null

func AttemptRCInteract():
	var level = ag.hoveredLevel
	var coords = ag.hoveredTile
	
	print("Player attempts a [RC] Interact at %s %s" % [level, coords])
	
	if level - ag.currentLevel in [-1, -2]:
		
		if player.inventory.AttemptRemove(player.toPlaceItem, 1):
			print("Placing Block...")
			var tm = get_node("LevelMaps/LevelMap" + str(level+1))
			var blockId = tm.tile_set.find_tile_by_name(player.toPlace)
			
			if player.toPlaceRot == "Down":
				tm.set_cellv(coords, blockId, false, true)
			elif player.toPlaceRot == "Left":
				tm.set_cellv(coords, blockId, false, false, true)
			elif player.toPlaceRot == "Right":
				tm.set_cellv(coords, blockId, true, false, true)
			else:
				tm.set_cellv(coords, blockId)
			
			tm.update_bitmask_area(coords)
			UpdateEmptyColliders(level+1, coords)
			
			# do stuff when player is now out of the Item
			if not player.inventory.Contains(player.toPlaceItem):
				player.toPlace = ""
				player.toPlaceItem = ""

# l is level where block was placed/removed
func UpdateEmptyColliders(l, coords):
	var tmNew = get_node("LevelMaps/LevelMap" + str(l))
	var tmAbove = get_node("LevelMaps/LevelMap" + str(l+1))
	
	if tmNew.get_cellv(coords) == -1:  # Block just removed
		tmAbove.set_cellv(coords, 12)
	else:								# Block just added
		tmAbove.set_cellv(coords, -1)
		
		for y in range(-1, 2):
			for x in range(-1, 2):
				var v = coords + Vector2(x, y)
				if Vector2(x, y) != Vector2(0, 0):
					if tmNew.get_cellv(v) == -1 and tmAbove.get_cellv(v) == -1:
						print("Blocking off %s - %s" % [l+1, v])
						tmAbove.set_cellv(v, 12)


# F by default
func AttemptActiveInteract():
	var level = ag.hoveredLevel
	var coords = ag.hoveredTile
	print("Player attempts an [Active] Interact at %s %s" % [level, coords])
	
	var tileId = get_node("LevelMaps/LevelMap" + str(level)).get_cellv(coords)
	var tileType = get_node("LevelMaps/LevelMap" + str(level)).tile_set.tile_get_name(tileId)
	
	#var potObj = $Objects.get_node("OI_%s_%s_%s" % [level, coords.x, coords.y])
	var potObj = GetObjectInstance(level, coords.x, coords.y)
	
	if potObj:
		ag.get_node("HUD/ObjectInteraction").Activate(level, coords)

# T by default
func AttemptInspect():
	var level = ag.hoveredLevel
	var coords = ag.hoveredTile
	print("Player attempts an [Inspect] Interact at %s %s" % [level, coords])
	
	ag.get_node("HUD/InspectPopup").popup()
	
	var tileType = get_node("LevelMaps/LevelMap" + str(level)).get_cellv(coords)
	tileType = get_node("LevelMaps/LevelMap" + str(level)).tile_set.tile_get_name(tileType)
	var iText = Database.GetValue("Blocks", tileType, "inspection")
	
	ag.get_node("HUD/InspectPopup/NinePatchRect/Label").text = iText


func Rotate(rads):
	player.rotate(rads)
	
	# rotate all Objects
	#var tsName = $LevelMaps/LevelMap3.tile_set.resource_path.split("/")[-1].split(".")[0]
	var tsName = tileSet.resource_path.split("/")[-1].split(".")[0]
	var objectIds = Constants.objectTileIds[tsName]
	
	var s = sign(rads)
	print(s)
	
	# todo: do this for all level maps, not just this one
	for l in range(5):
		for oId in objectIds:
			print(oId)
			#var objectCoords = $LevelMaps/LevelMap3.get_used_cells_by_id(oId)
			var objectCoords = get_node("LevelMaps/LevelMap" + str(l)).get_used_cells_by_id(oId)
			for oc in objectCoords:
				print("\t", oc)
				
				#var curr = $LevelMaps/LevelMap3.get_cell_autotile_coord(oc.x, oc.y)
				var curr = get_node("LevelMaps/LevelMap" + str(l)).get_cell_autotile_coord(oc.x, oc.y)	
				print("\t", curr)
				
				var new = curr + Vector2(s, 0)
				new.x = wrapi(new.x, 0, 4)
				print("\t", new)
				
				#$LevelMaps/LevelMap3.set_cell(oc.x, oc.y, oId, false, false, false, new)
				get_node("LevelMaps/LevelMap" + str(l)).set_cell(oc.x, oc.y, oId, false, false, false, new)


func GetIconTexture(tileName):
	var tileId = tileSet.find_tile_by_name(tileName)
	
	var tx = tileSet.tile_get_texture(tileId)
	var txr = tileSet.tile_get_region(tileId)
	var ic = tileSet.autotile_get_icon_coordinate(tileId)
	
	var atx = AtlasTexture.new()
	atx.atlas = tx
	atx.region = Rect2(txr.position + ic * 32, Vector2(32, 32))
	
	return atx

func GetObjectInstance(l, x, y):
	return $Objects.get_node("OI_%s_%s_%s" % [l, x, y])
