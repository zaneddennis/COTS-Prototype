extends Control


onready var player = get_parent().get_parent().get_node("Planet/Characters/Player")

var selectedItem = "Dirt"
onready var selectedPos = $NinePatchRect/Selector.rect_position
var selectedBlock = "Dirt_Autotile"
onready var selectedBlockPos = $NinePatchRect2/Selector.rect_position


func _ready():
	pass


func Activate():
	show()
	
	var inv = player.inventory
	
	# display Items
	var tx = 16
	var mx = 16
	for item in inv.Names():
		var bType = Database.GetValue("Items", item, "blockType")
		var q = inv.Get(item)
		
		match bType:
			"":
				pass
			"Terrain":
				var y = 32
				var tr = TextureRect.new()
				
				tr.rect_min_size = Vector2(64, 64)
				$NinePatchRect/Terrains.add_child(tr)
				tr.rect_position = Vector2(tx, y)
				tx += 72
				
				var iTx = Database.GetValue("Items", item, "_InvSprite").texture
				tr.texture = iTx
				
				tr.connect("mouse_entered", self, "_on_mouse_over_item", [item, $NinePatchRect/Terrains.rect_position + tr.rect_position])
				tr.connect("mouse_exited", self, "_on_mouse_exited_item", [item])
				tr.connect("gui_input", self, "_on_item_gui_input", [item, $NinePatchRect/Terrains.rect_position + tr.rect_position])
				
				var l = Label.new()
				tr.add_child(l)
				l.text = str(q)
				l.anchor_top = 1
				l.anchor_bottom = 1
				l.anchor_left = 1
				l.anchor_right = 1
				l.margin_top = -14
				l.margin_bottom = -2
				l.margin_left = -12
				l.margin_right = 0
				
			"Module":
				pass
	
	Select(selectedItem)


func ActivateBlocks(i):
	var blocks = Database.GetValue("Items", i, "placeables")
	
	var j = 0
	for cr in $NinePatchRect2/Placeables/GridContainer.get_children():
		if j < len(blocks):
			var b = blocks[j]
			
			var tr = TextureRect.new()
			tr.expand = true
			
			tr.rect_min_size = Vector2(64, 64)
			$NinePatchRect2/Placeables.add_child(tr)
			tr.rect_position = cr.rect_position + Vector2(8, 0)
			
			tr.texture = get_node("../../Planet").GetIconTexture(b)
			
			tr.connect("mouse_entered", self, "_on_mouse_over_block", [b, $NinePatchRect2/Placeables.rect_position + cr.rect_position + Vector2(8, 0)])
			tr.connect("mouse_exited", self, "_on_mouse_exited_block", [b])
			tr.connect("gui_input", self, "_on_block_gui_input", [b, $NinePatchRect2/Placeables.rect_position + cr.rect_position + Vector2(8, 0)])
		
		j += 1

func ActivateRotations():
	$NinePatchRect3.show()
	
	var m = get_node("../../Planet/LevelMaps/LevelMap0")
	var tx = m.tile_set.tile_get_texture(m.tile_set.find_tile_by_name(selectedBlock))
	var txr = m.tile_set.tile_get_region(m.tile_set.find_tile_by_name(selectedBlock))
	var ic = m.tile_set.autotile_get_icon_coordinate(m.tile_set.find_tile_by_name(selectedBlock))
	
	var atx = AtlasTexture.new()
	atx.atlas = tx
	atx.region = Rect2(txr.position + ic * 32, Vector2(32, 32))
	
	for dir in ["Right", "Left", "Up", "Down"]:
		var tr = get_node("NinePatchRect3/ColorRect%s/TextureRect" % [dir])
		tr.texture = atx
		tr.connect("gui_input", self, "_on_rotation_gui_input", [dir, get_node("NinePatchRect3/ColorRect%s" % [dir]).rect_position])


func Close():
	hide()
	
	for n in $NinePatchRect/Terrains.get_children():
		if n is TextureRect:
			n.queue_free()
	
	for n in $NinePatchRect2/Placeables.get_children():
		if n is TextureRect:
			n.queue_free()


func Hover(i, pos):
	$NinePatchRect/Selected/Label.text = str(i)
	$NinePatchRect/Selector.rect_position = pos

func Select(i):
	$NinePatchRect/Selected/Label.text = "SELECTED: " + str(i)
	
	if selectedItem != i:
		selectedItem = i
		selectedPos = $NinePatchRect/Selector.rect_position
		
		var placeables = Database.GetValue("Items", i, "placeables")
		player.toPlace = placeables[0]
		player.toPlaceItem = i
	
	ActivateBlocks(i)
	SelectBlock(player.toPlace)

func SelectBlock(b):
	$NinePatchRect2/Placeables/Label.text = "SELECTED: " + Database.GetValue("Blocks", b, "displayName")
	selectedBlock = b
	selectedBlockPos = $NinePatchRect2/Selector.rect_position
	
	player.toPlace = b
	
	if Database.GetValue("Blocks", b, "rotates"):
		ActivateRotations()
		player.toPlaceRot = "Up"
	else:
		$NinePatchRect3.hide()
		player.toPlaceRot = ""

func SelectRotation(dir):
	player.toPlaceRot = dir


func _on_mouse_over_item(i, pos):
	Hover(i, pos)

func _on_mouse_exited_item(i):
	$NinePatchRect/Selected/Label.text = "SELECTED: " + selectedItem
	$NinePatchRect/Selector.rect_position = selectedPos

func _on_item_gui_input(event, i, pos):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			Select(i)


func _on_mouse_over_block(b, pos):
	$NinePatchRect2/Placeables/Label.text = Database.GetValue("Blocks", b, "displayName")  # HERE: use displayName instead of just b
	$NinePatchRect2/Selector.rect_position = pos

func _on_mouse_exited_block(b):
	$NinePatchRect2/Placeables/Label.text = "SELECTED: " + Database.GetValue("Blocks", selectedBlock, "displayName")
	$NinePatchRect2/Selector.rect_position = selectedBlockPos
	
	if Database.GetValue("Blocks", selectedBlock, "rotates"):
		ActivateRotations()
	else:
		$NinePatchRect3.hide()

func _on_block_gui_input(event, b, pos):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			SelectBlock(b)


func _on_rotation_gui_input(event, dir, pos):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			$NinePatchRect3/Selector.rect_position = pos
			SelectRotation(dir)
