extends Popup


func _ready():
	pass


func Activate(level, coords):
	$PlayerInterfaces/InventoryMotif.Activate()
	
	# todo: make a GetObjectInstance(l, x, y) function in Planet.gd? and GetOIPath(l, x, y)?
	var np = NodePath("/root/ActiveGame/Planet/Objects/OI_%s_%s_%s/Inventory" % [level, coords.x, coords.y])
	if get_node(np):
		$ObjectInterfaces/InventoryMotif.invPath = np
		$ObjectInterfaces/InventoryMotif.Activate()
	
		$ObjectInterfaces/TakeAll.show()
	
	popup()
	get_node("/root/ActiveGame/InputHandler").standardInput = false

func Clear():
	get_node("/root/ActiveGame/InputHandler").standardInput = true
	$ObjectInterfaces/InventoryMotif.Clear()
	$PlayerInterfaces/InventoryMotif.Clear()
	$ObjectInterfaces/TakeAll.hide()


func _on_TakeAll_pressed():
	var oi = $ObjectInterfaces/InventoryMotif.inventory
	var pi = $PlayerInterfaces/InventoryMotif.inventory
	
	# for item in Object Inventory
	for i in oi.Names():
		# remove from OI
		var q = oi.Get(i)
		oi.AttemptRemove(i, q)
		
		# add to Player Inventory
		pi.AttemptAdd(i, q)
	
	# refresh interface
	$ObjectInterfaces/InventoryMotif.Activate()
	$PlayerInterfaces/InventoryMotif.Activate()


func _on_Object_Inv_LC(i):
	var oi = $ObjectInterfaces/InventoryMotif.inventory
	var pi = $PlayerInterfaces/InventoryMotif.inventory
	
	var q = oi.Get(i)
	oi.AttemptRemove(i, q)
	pi.AttemptAdd(i, q)
	
	$ObjectInterfaces/InventoryMotif.Activate()
	$PlayerInterfaces/InventoryMotif.Activate()


func _on_Object_Inv_RC(i):
	var oi = $ObjectInterfaces/InventoryMotif.inventory
	var pi = $PlayerInterfaces/InventoryMotif.inventory
	
	oi.AttemptRemove(i, 1)
	pi.AttemptAdd(i, 1)
	
	$ObjectInterfaces/InventoryMotif.Activate()
	$PlayerInterfaces/InventoryMotif.Activate()


func _on_ObjectInteraction_popup_hide():
	Clear()
