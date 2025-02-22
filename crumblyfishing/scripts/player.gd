extends CharacterBody3D

const tracksuitTxt = preload("res://Textures/Player/Tracksuit.png")
const overallsTxt = preload("res://Textures/Player/OverAlls.png")
const lumberjackTxt = preload("res://Textures/Player/LumberJackOutFit.png")

@onready var camera = $Camera3D
@onready var anim = $Camera3D/Hand/AnimationPlayer
@onready var bodyHolder = $Graphics/BodyHolder
@onready var inputSynch = $inputSynchronizer
@onready var reach = $Camera3D/Reach as RayCast3D
@onready var hand = $Camera3D/Hand
@onready var progressBar = $Camera3D/Control/ProgressBar
var activeItem

@onready var fishingRodItem = $Camera3D/Hand/FishingRod
@onready var beerBottleItem = $Camera3D/Hand/BeerBottle

var lastUse = false
var useTimer = 0.0
var bufferJump = false

var username = "Guest"
var outfit = 0

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

var idle = true

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	pass

func _ready() -> void:
	if not is_multiplayer_authority(): return
	bodyHolder.rotate(Vector3.RIGHT,-PI/8)
	bodyHolder.position.z = -0.3
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Label3D.hide()
	fishingRodItem.player = self
	beerBottleItem.player = self

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _process(_delta: float) -> void:
	if not inputSynch.jump:
		bufferJump = false
	elif bufferJump == false:
		bufferJump = true
	
	if not inputSynch.use:
		if useTimer != 0.0 and activeItem:
			activeItem.stopUse()
		useTimer = 0.0
	else:
		useTimer += _delta
	
	if inputSynch.use and activeItem:
		activeItem.use(useTimer)
	if inputSynch.interact and reach.is_colliding() and not activeItem:
			_interact()
	if inputSynch.drop and activeItem:
		dropHand()
	
	lastUse = inputSynch.use	

func _interact():
	if reach.get_collider().get_name() == "FishingRodStand":
		resetHand()
		fishingRodItem.show()
		fishingRodItem.durability = 50
		activeItem = fishingRodItem
		activeItem.player = self
		activeItem.itemSetup("default")
		return 
	if reach.get_collider().get_name() == "BeerBottleStand":
		resetHand()
		beerBottleItem.show()
		beerBottleItem.fillLevel = 1
		activeItem = beerBottleItem
		activeItem.player = self
		activeItem.itemSetup("default")
		return 
	
	var item = reach.get_collider() as Item
	if not item:return
	match item.type:
		1:
			resetHand()
			fishingRodItem.show()
			Global.removeObject.rpc(reach.get_collider().get_path())
			activeItem = fishingRodItem
			activeItem.itemSetup(reach.get_collider().getVars())
			return 

		2:
			resetHand()
			beerBottleItem.show()
			Global.removeObject.rpc(reach.get_collider().get_path())
			activeItem = beerBottleItem
			activeItem.itemSetup(reach.get_collider().getVars())
			return
		
func dropHand():
	
	var dropItem = null
	match activeItem:
		fishingRodItem:
			dropItem =Global.fishingRodPickup
		beerBottleItem:
			dropItem = Global.beerBottlePickup
	
	Global.createItem.rpc(dropItem,hand.global_transform,true,activeItem.id,activeItem.getVars())
	
	resetHand()
	activeItem = null

func resetHand():
	for n in range(1,hand.get_child_count()):
		hand.get_child(n).hide()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		SPEED = 5.0;
		velocity += get_gravity() * delta
	else:
		if inputSynch.sprint:
			SPEED = 8.0;
		else:
			SPEED = 5.0;
	
	# Handle jump.
	if (inputSynch.jump or bufferJump) and is_on_floor():
		bufferJump = false
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = inputSynch.inputDirection
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	if idle:
		if input_dir != Vector2.ZERO and is_on_floor():
			anim.play("Move")
		else:
			anim.play("Idle")

	move_and_slide()

func setPlayerOutfit( _outfit :int):
	outfit = _outfit
	bodyHolder.get_child(outfit).show()
	
func setPlayerName(_username):
	print(_username)
	username = _username
	$Label3D.text = _username
