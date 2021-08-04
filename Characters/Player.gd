extends "res://Characters/Character.gd"


var wielding = "Hand"
var spriteOrder = ["Hand", "Shovel", "Pick", "Axe", "Bottle", "Rod"]

var toPlace = "Dirt_Autotile"
var toPlaceItem = "Dirt"  # for interacting with Inventory
var toPlaceRot = ""

onready var inventory = $Inventory


func _ready():
	pass

func _process(delta):
	pass


# todo: move literally all of this up to Character.gd ()
func Wield(t):
	if Database.Contains("Tools", t):
		wielding = t
		
		# set sprite region
		var ix = spriteOrder.find(t)
		$ToolSprite.region_rect.position.x = 32*ix
		
		print("Player is now wielding " + t)
	else:
		print("ERROR: %s not in Database" % [t])

func Swing(iTime):
	$ToolSprite/AnimationPlayer.play("Swing")
	
	$ProgressBar.value = 0
	$ProgressBar/InteractTimer.start(iTime)
	$ProgressBar.show()

func StopInteract():
	$ToolSprite/AnimationPlayer.seek(0, true)
	$ToolSprite/AnimationPlayer.stop()
	$ProgressBar.hide()
	
	$ProgressBar/InteractTimer.stop()
	

func FinishInteract():
	StopInteract()
	get_parent().get_parent().CompleteLCInteract()


func _on_InteractTimer_timeout():
	FinishInteract()
