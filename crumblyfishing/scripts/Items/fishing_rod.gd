extends Item

var durability = 50

const dropItem = preload("res://Scenes/fishing_rod_Pickup.tscn")

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func use():
	durability -= 1;
	print("Durability is %d", durability)
	
func repair():
	durability = 50
	print("Durability restored to %d", durability)
	
