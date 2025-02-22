extends Item

@export var durability : int
var player = null
var anim = false

var loading

func _ready() -> void: 
	type = 1
	
func _process(_delta: float) -> void:
	pass

func use(_useTimer):	
	if _useTimer > 0.5:
		Global.localPlayer.progressBar.show()
		if not anim:
			player.idle = false
			player.anim.play("Cast")
			player.anim.seek(0.5)
			anim = true
	
	loading = fmod(_useTimer,3.0)
	if int(floor(_useTimer / 3.0)) % 2 == 1:
		loading = 3.0 - loading 
	loading *= 33.3333
	Global.localPlayer.progressBar.value = loading
	
func repair():
	durability = 50
	print("Durability restored to %d", durability)
	
func stopUse():
	Global.localPlayer.progressBar.hide()
	anim = false
	player.idle = true
	if loading > 16.6666:
		#CAST
		player.idle = false
		player.anim.play("Cast_flick")
		await get_tree().create_timer(0.25).timeout
		player.idle = true
		print("Casting with ",loading)
	
func itemSetup(vars):
	if str(vars) == "default":
		id = Global.getNewObjectId()
		durability = 50
		return
	id = vars[0]
	durability = vars[1]
func getVars():
	return [id,durability]
