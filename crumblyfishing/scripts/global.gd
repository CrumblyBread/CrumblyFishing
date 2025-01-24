extends Node3D

const menu = preload("res://Scenes/main_menu.tscn")

var global_scene
var mainMenu_scene
var world_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.global_scene = self
	mainMenu_scene = menu.instantiate()
	add_child(mainMenu_scene)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
