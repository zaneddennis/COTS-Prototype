extends Control


signal mouseover_item(i)
signal mouseexit_item()
signal lclick_item(i)
signal rclick_item(i)


export var dev_dimensions = Vector2(8, 3)
export(NodePath) var invPath

var inventory
var keys


func _ready():
	pass

func _process(delta):
	pass


func Activate():
	Clear()
	print(invPath)
	
	inventory = get_node(invPath)
	var d = inventory.dimensions
	keys = inventory.Names()
	
	print(inventory.data)
	
	$Bg_GridContainer.columns = d.x
	$Tx_GridContainer.columns = d.x
	
	for i in range(d.x * d.y):
		var cr = ColorRect.new()
		cr.rect_min_size = Vector2(64, 64)
		$Bg_GridContainer.add_child(cr)
		cr.color = ColorN("darkgray")
		
		if i < len(keys):
			var k = keys[i]
			var q = inventory.Get(k)
			
			var tr = TextureRect.new()
			tr.rect_min_size = Vector2(64, 64)
			$Tx_GridContainer.add_child(tr)
			var kTx = Database.GetValue("Items", k, "_InvSprite").texture
			tr.texture = kTx
			tr.connect("mouse_entered", self, "_on_mouse_over_item", [k])
			tr.connect("mouse_exited", self, "_on_mouse_exit_item")
			tr.connect("gui_input", self, "_on_InventoryMotif_gui_input", [k])
			
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
	
	$ItemName_Label.rect_position.y = 64 * d.y + 8 * d.y
	$ItemName_Label.text = ""

func Clear():
	for n in $Bg_GridContainer.get_children():
		n.queue_free()
	for n in $Tx_GridContainer.get_children():
		n.queue_free()


func _on_mouse_over_item(iName):
	$ItemName_Label.text = iName
	emit_signal("mouseover_item", iName)

func _on_mouse_exit_item():
	$ItemName_Label.text = ""
	emit_signal("mouseexit_item")


func _on_InventoryMotif_gui_input(event, i):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			emit_signal("lclick_item", i)
		elif event.button_index == BUTTON_RIGHT and not event.pressed:
			emit_signal("rclick_item", i)
