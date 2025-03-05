extends Item

@export var durability : int
var player = null
var anim = false
@onready var tip = $Tip
@onready var bober = $Bobber

var loading

func _ready() -> void: 
	type = 1
	bober.set_freeze_enabled(true)
	
func _process(_delta: float) -> void:
	pass

func use(_useTimer):	
	if _useTimer > 0.5:
		bober.hide()
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
		cast(loading)
	else:
		bober.show()

func cast(force):
	bober.show()
	#bober.get_child(2).set_root_path(Global.world_scene.get_path())
	self.remove_child(bober)
	Global.add_child(bober)
	bober.set_freeze_enabled(false)
	bober.global_position = tip.global_position
	bober.rotation = Vector3.ZERO
	bober.get_child(0).scale = Vector3(1,1,1)
	bober.apply_impulse(bober.position,-tip.basis.z * 500 * force)
	
	player.idle = false
	player.anim.play("Cast_flick")
	await get_tree().create_timer(0.25).timeout
	player.idle = true
	print("Casting with ",force)
	
	
func itemSetup(vars):
	if str(vars) == "default":
		id = Global.getNewObjectId()
		durability = 50
		return
	id = vars[0]
	durability = vars[1]
func getVars():
	return [id,durability]
