extends Item

@export var durability : int
var player = null

func _ready() -> void: 
	type = 1
	
func _process(_delta: float) -> void:
	pass

func use(_useTimer):
	
	if _useTimer > 0.3:
		Global.localPlayer.progressBar.show()	
	
	var loading = fmod(_useTimer,3.0)
	if int(floor(_useTimer / 3.0)) % 2 == 1:
		loading = 3.0 - loading 
	loading *= 33.3333
	Global.localPlayer.progressBar.value = loading
	
func stopUse():
	Global.localPlayer.progressBar.hide()
	
func itemSetup(vars):
	print(str(vars) == "default")
	if str(vars) == "default":
		id = Global.getNewObjectId()
		durability = 50
		return
	id = vars[0]
	durability = vars[1]
func getVars():
	return [id,durability]
	
func repair():
	durability = 50
	print("Durability restored to %d", durability)
