extends Item

@export var fillLevel = 1.0
var lastUseTimer = 0.0
var player = null
var anim = false

func _ready() -> void:
	type = 2
	
func use(_useTimer):
	if _useTimer < 0.5: return
	if not anim and fillLevel > 0:
		player.idle = false
		player.anim.play("Drink_windup")
		anim = true
	if _useTimer > 1: 
		if fillLevel > 0:
			player.anim.play("Drink")
			fillLevel -= (_useTimer - lastUseTimer) / 6
		else:
			noDrink()
		lastUseTimer = _useTimer
func noDrink():
	lastUseTimer = 0.0
	player.idle = true
	anim = false
	
func stopUse():
	if lastUseTimer > 0.5:
		player.anim.play("Drink_winddown")
		await get_tree().create_timer(0.5).timeout
		player.idle = true
		anim = false
	lastUseTimer = 0.0
	

func itemSetup(vars):
	if str(vars) == "default":
		id = Global.getNewObjectId()
		fillLevel = 1
		return
	id = vars[0]
	fillLevel = vars[1]
func getVars():
	return [id,fillLevel]
