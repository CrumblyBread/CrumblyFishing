extends Area3D


func _on_body_entered(body: Node3D) -> void:
	var rb = body as RigidBody3D
	if not rb: return
	body.global_position = Vector3.ZERO
	body.rotation = Vector3.ZERO
	rb.linear_velocity.y = 0
