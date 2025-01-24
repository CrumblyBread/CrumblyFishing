extends Node3D

const tracksuitTxt = preload("res://Textures/Player/Tracksuit.png")
const overallsTxt = preload("res://Textures/Player/OverAlls.png")
const lumberjackTxt = preload("res://Textures/Player/LumberJackOutFit.png")
const Player = preload("res://Scenes/player.tscn")

@onready var playMenu = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayMenu
@onready var mainMenu = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MainMenu

@onready var usernameField = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayMenu/LineEdit
@onready var OutfitField = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayMenu/OptionButton

@onready var joinMenu = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/JoinMenu
@onready var hostMenu = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HostMenu

@onready var outfitBody = $Player/Graphics/Body

@onready var hostPortField = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HostMenu/HostPort
@onready var joinPortField = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/JoinMenu/PortEntry

var port = 5430
var username
var outfit

var enet_peer = ENetMultiplayerPeer.new()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	mainMenu.hide()
	playMenu.show()


func _backToMenuPressed(parent: String) -> void:
	get_node(parent).hide()
	mainMenu.show()


func _on_backToPlayMenu(parent: String) -> void:
	playMenu.show()
	get_node(parent).hide()


func _on_JoinMenu_button_pressed() -> void:
	playMenu.hide()
	joinMenu.show()


func _on_hostMenu_button_pressed() -> void:
	playMenu.hide()
	hostMenu.show()


func _on_option_button_item_selected(index: int) -> void:
	outfit = index
	match index:
		0:
			outfitBody.mesh.material.albedo_texture = tracksuitTxt
		1:
			outfitBody.mesh.material.albedo_texture = overallsTxt
		2:
			outfitBody.mesh.material.albedo_texture = lumberjackTxt

func StartServerButton() -> void:
	if hostPortField.text != "" or null:
		port = hostPortField.text
	
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer

func JoinServerButton() -> void:
	pass # Replace with function body.

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		mainMenu.visible = !mainMenu.visible
