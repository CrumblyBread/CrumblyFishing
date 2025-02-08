extends Node3D

const menu = preload("res://Scenes/main_menu.tscn")
const player = preload("res://Scenes/player.tscn")
const world = preload("res://Scenes/world.tscn")

var playerHolder
var objectsHolder

var global_scene
var mainMenu_scene
var world_scene

var localPlayerId

var ip
var port

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if Global.global_scene == null:
		Global.global_scene = self
	else:
		self.queue_free()
		return
	
	var menuScene = menu.instantiate()
	Global.mainMenu_scene = menuScene
	add_child(menuScene)

func createWorld():
	if Global.world_scene == null:
		var instance = world.instantiate()
		Global.world_scene = instance
		Global.add_child(instance)
		Global.playerHolder = Global.world_scene.get_node("Players")
		Global.objectsHolder = Global.world_scene.get_node("Objects")

func addPlayer(peer_id):
	var p = player.instantiate()
	p.name = str(peer_id)
	createWorld()
	Global.playerHolder.add_child(p)
	p.get_child(2).set_multiplayer_authority(peer_id)
	
func removePlayer(peer_id):
	var p = Global.playerHolder.get_node_or_null(str(peer_id))
	if p:
		p.queue_free()

func UpnpSetup():
	var upnp = UPNP.new()
	
	var discorver = upnp.discover()
	assert(discorver == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discorver)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
	
	var map = upnp.add_port_mapping(Global.port)
	assert(map == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map)
	print("Success! Join address %s" % upnp.query_external_address())
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

@rpc("any_peer", "reliable", "call_local")
func removeObject(node_path):
	var object = get_node(node_path)
	object.queue_free()
	
@rpc("any_peer", "reliable", "call_local")
func createObject(load_path,hand,drop):
	var spawnItem = load(load_path).instantiate() as Node3D
	Global.objectsHolder.add_child(spawnItem)
	spawnItem.position = hand.origin
	spawnItem.rotation = Vector3(hand.basis.get_euler().x,hand.basis.get_euler().y+90,hand.basis.get_euler().z)
	if drop:
		spawnItem.apply_impulse(spawnItem.basis.x,-spawnItem.basis.x * 500)
