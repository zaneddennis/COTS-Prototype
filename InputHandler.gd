extends Node


onready var ag = get_parent()
onready var player = ag.get_node("Planet/Characters/Player")
onready var hud = ag.get_node("HUD")

var standardInput = true


func _ready():
	pass


func _process(delta):
	HandleUI()
	
	if standardInput:
		HandleCamera()
	
		HandleMovement()
	
		HandleInteract()


func HandleCamera():
	if Input.is_action_just_pressed("rotate_left"):
		ag.get_node("Planet").Rotate(-1 * PI/2)
	elif Input.is_action_just_pressed("rotate_right"):
		ag.get_node("Planet").Rotate(PI/2)

func HandleUI():
	if standardInput:
		if Input.is_action_just_pressed("tool_select"):
			hud.get_node("ToolSelect").Activate()
		if Input.is_action_just_released("tool_select"):
			var selection = hud.get_node("ToolSelect").Close()
			player.Wield(selection)
		
		if Input.is_action_just_pressed("build_menu"):
			hud.get_node("BuildMenu").Activate()
		if Input.is_action_just_released("build_menu"):
			hud.get_node("BuildMenu").Close()
	
	HandlePlayerPanels()

func HandlePlayerPanels():
	if Input.is_action_just_pressed("menu_panel"):
		hud.get_node("PlayerPanels").ActivatePanel("Menu")
	if Input.is_action_just_pressed("inventory_panel"):
		hud.get_node("PlayerPanels").ActivatePanel("Inventory")

func HandleMovement():
	player.velocity = Vector2(0, 0)
	if Input.is_action_pressed("move_up"):
		player.velocity += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		player.velocity += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		player.velocity += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		player.velocity += Vector2(1, 0)
	
	player.HandleMovement()

func HandleInteract():
	if ag.hoveredTile != null:
		HandleMouseOnTile()

func HandleMouseOnTile():
	if Input.is_action_just_pressed("interact_active"):
		ag.get_node("Planet").AttemptActiveInteract()
	if Input.is_action_just_pressed("inspect"):
		ag.get_node("Planet").AttemptInspect()
	
	elif Input.is_action_just_pressed("left_click"):
		ag.get_node("Planet").AttemptLCInteract()
	elif Input.is_action_just_pressed("right_click"):
		ag.get_node("Planet").AttemptRCInteract()
	
	if Input.is_action_just_released("left_click"):
		player.StopInteract()
