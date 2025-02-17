extends Item

@export var fillLevel = 1.0
var lastUseTimer = 0.0

func _ready() -> void:
	type = 2

func itemSetup(vars):
	print(vars)
	if str(vars) == "default":
		id = Global.getNewObjectId()
		fillLevel = 1
		return
	id = vars[0]
	fillLevel = vars[1]
func getVars():
	return [id,fillLevel]

func use(_useTimer):
	if _useTimer < 0.3: return
	if fillLevel > 0:
		fillLevel -= 0.5 * (_useTimer - lastUseTimer)
	lastUseTimer = _useTimer
	
func stopUse():
	lastUseTimer = 0.0

func _process(_delta: float) -> void:
	pass
