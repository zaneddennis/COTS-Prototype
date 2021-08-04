tool
extends Control


export var radiusInner = 64
export var radiusOuter = 256
export var slices = [null, null, null]

export var iconsPath = ""
export var iconSize = 32
onready var iconsTexture = load("res://" + iconsPath)

onready var pos = get_viewport_rect().size/2

var icons = []


# NOTE: not intended for < 3 slices! (inner, top, bottom)


func _ready():
	pass

func _draw():
	draw_circle(pos, radiusOuter, ColorN("darkgray", 0.75))
	draw_arc(pos, radiusInner, 0, 2*PI, 256, ColorN("black"))
	
	for i in range(len(slices)-1):
		var rads = (2 * PI * i) / (len(slices)-1)
		var pointNorm = Vector2(cos(rads), sin(rads))
		draw_line(pos+pointNorm*radiusInner, pos+pointNorm*radiusOuter, ColorN("black"))
	
	if iconsPath:
		draw_texture_rect_region(iconsTexture, Rect2(pos - Vector2(16, 16), Vector2(32, 32)), Rect2(0, 0, 32, 32))
		for i in range(1, len(slices)):
			var startRads = (2 * PI * (i-1)) / (len(slices)-1)
			var endRads = (2 * PI * i) / (len(slices)-1)
			var midRads = (startRads + endRads) / -2.0  # is there no mean() or avg() function in GDScript?
			var radiusMid = (radiusInner + radiusOuter) / 2.0
			
			var drawPos = pos + radiusMid*Vector2(cos(midRads), sin(midRads)) - Vector2(16, 16)
			draw_texture_rect_region(iconsTexture, Rect2(drawPos, Vector2(32, 32)), Rect2(32*i, 0, 32, 32))

func _process(delta):
	if Engine.editor_hint:
		update()


func Activate():
	show()

func Close():
	hide()
	
	var mPos = (get_local_mouse_position() - pos) * Vector2(-1, 1)
	var mRadius = pos.distance_to(get_local_mouse_position())
	if mRadius < radiusInner:
		return slices[0]
	
	var frac = (mPos.angle() + PI) / (2*PI)
	var i = int(ceil(frac * (len(slices)-1)))
	
	return slices[i]
