extends CharacterBody3D

const tracksuitTxt = preload("res://Textures/Player/Tracksuit.png")
const overallsTxt = preload("res://Textures/Player/OverAlls.png")
const lumberjackTxt = preload("res://Textures/Player/LumberJackOutFit.png")

@onready var camera = $Camera3D
@onready var anim = $Camera3D/Hand/AnimationPlayer
@onready var bodyHolder = $Graphics/BodyHolder
@onready var inputSynch = $inputSynchronizer
@onready var reach = $Camera3D/Reach
@onready var hand = $Graphics/Head

var activeItem

@onready var fishingRodItem = $Camera3D/Hand/FishingRod

const fishingRodPickup = preload("res://Scenes/fishing_rod_Pickup.tscn")

var username = "Guest"
var outfit = 0

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	pass

func _ready() -> void:
	if not is_multiplayer_authority(): return
	bodyHolder.rotate(Vector3.RIGHT,-PI/8)
	bodyHolder.position.z = -0.2
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Label3D.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _process(_delta: float) -> void:
	if inputSynch.interact and reach.is_colliding():
		_interact()
		
func _interact():
	if reach.get_collider().get_name() == "FishingRodPickUp":
		resetHand()
		fishingRodItem.show()
		fishingRodItem.durability = reach.get_collider().durability
		reach.get_collider().queue_free()
		activeItem = fishingRodItem
		return

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
	if inputSynch.jump and is_on_floor():
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
