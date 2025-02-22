extends Node3D

const menu = preload("res://Scenes/main_menu.tscn")
const player = preload("res://Scenes/player.tscn")
const world = preload("res://Scenes/world.tscn")

const fishingRodPickup = "res://Scenes/fishing_rod_Pickup.tscn"
const beerBottlePickup = "res://Scenes/beer_bottle_pick_up.tscn"

var playerHolder
var objectsHolder

var global_scene
var mainMenu_scene
var world_scene

var localPlayerId
var localPlayer

var ip
var port

var nextObjectId = 1

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
		
func objectSynch():
	for n in Global.objectsHolder.get_children():
		n.queue_free()

func addPlayer(peer_id):
	var p = player.instantiate()
	p.name = str(peer_id)
	createWorld()
	Global.playerHolder.add_child(p)
	p.get_child(2).set_multiplayer_authority(peer_id)
	getLocalPlayer()
	if peer_id != 1 and multiplayer.is_server():
		for n in Global.objectsHolder.get_children():
			var it = n as Item
			var path
			match it.type:
				1:
					path = fishingRodPickup
				2:
					path = beerBottlePickup
			Global.createItem.rpc_id(peer_id,path,n.global_transform,false,it.id,it.getVars())
	
func removePlayer(peer_id):
	var p = Global.playerHolder.get_node_or_null(str(peer_id))
	if p:
		p.queue_free()

func getLocalPlayer():
	if localPlayer: return
	for n in Global.playerHolder.get_children():
		if n.name == str(multiplayer.get_unique_id()):
			Global.localPlayer = n

func getNewObjectId():
	nextObjectId += 1
	return nextObjectId - 1

func getVarsFromId(_id):
	for p in Global.playerHolder.get_children():
		if p.activeItem and p.activeItem.id == _id:
			return p.activeItem.getVars()
	for item in Global.objectsHolder.get_children():
		if item and item is Item and item.id == _id:
			return item.getVars()

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
	var spawnItem = load(load_path).instantiate() as Item
	Global.objectsHolder.add_child(spawnItem)
	spawnItem.position = hand.origin
	spawnItem.rotation = Vector3(hand.basis.get_euler().x,hand.basis.get_euler().y+90,hand.basis.get_euler().z)
	if drop:
		spawnItem.apply_impulse(spawnItem.basis.x,-spawnItem.basis.x * 500)

@rpc("any_peer", "reliable", "call_local")
func createItem(load_path,hand,drop,_itemId,vars):
	var spawnItem = load(load_path).instantiate() as Item
	Global.objectsHolder.add_child(spawnItem)
	spawnItem.position = hand.origin
	spawnItem.rotation = Vector3(hand.basis.get_euler().x,hand.basis.get_euler().y+90,hand.basis.get_euler().z)
	if drop:
		spawnItem.apply_impulse(spawnItem.basis.x,-spawnItem.basis.x * 500)
		
	var spawnVars = getVarsFromId(_itemId)
	if not spawnVars:
		spawnVars = vars
	
	if _itemId != 0:
		spawnItem.itemSetup(spawnVars)
	else:
		spawnItem.itemSetup("default")
