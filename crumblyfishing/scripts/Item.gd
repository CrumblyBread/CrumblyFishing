extends Node3D
class_name Item

@export var item_name : String
@export var cost : float
@export var type = 0
@export var id = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func itemSetup(_vars):
	pass
func getVars():
	pass
func use(_useTimer):
	pass
func stopUse():
	pass
