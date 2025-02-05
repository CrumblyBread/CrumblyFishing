extends MultiplayerSynchronizer

var inputDirection : Vector2
var jump
var use
var interact
var sprint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	inputDirection = Input.get_vector("left", "right", "up", "down")
	jump = Input.is_action_just_pressed("ui_accept")
	use = Input.is_action_just_pressed("use")
	interact = Input.is_action_just_pressed("interact")
	sprint = Input.is_action_pressed("sprint")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	inputDirection = Input.get_vector("left", "right", "up", "down")
	jump = Input.is_action_just_pressed("ui_accept")
	use = Input.is_action_just_pressed("use")
	interact = Input.is_action_just_pressed("interact")
	sprint = Input.is_action_pressed("sprint")
