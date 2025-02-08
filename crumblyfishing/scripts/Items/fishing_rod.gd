extends Item

@export var durability : int

func _ready() -> void: 
	id = 1
	
func _process(_delta: float) -> void:
	pass

func use():
	durability -= 1;
	print("Durability is %d", durability)
	
func repair():
	durability = 50
	print("Durability restored to %d", durability)
