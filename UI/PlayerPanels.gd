extends TabContainer


func _ready():
	pass

func _process(delta):
	pass


func ActivatePanel(p, justChanged=false):
	if visible and get_node(p).visible and not justChanged:
		hide()
		get_node("/root/ActiveGame/InputHandler").standardInput = true
	else:
		var ix = get_node(p).get_index()
		var n = get_node(p)
		if n.get_script():
			n.Activate()
		
		current_tab = ix
		get_node("/root/ActiveGame/InputHandler").standardInput = false
		show()

func ClosePanel(p):
	if get_node(p).has_method("Clear"):
		get_node(p).Clear()


func _on_PlayerPanels_tab_changed(tab):
	# clear other panels
	for i in range(get_child_count()):
		if i != tab:
			var n = get_child(i)
			ClosePanel(n.name)
	
	ActivatePanel(get_child(tab).name, true)
