extends Area2D

signal player_entered

func _on_PlayerAreaTrigger_body_entered(body):
	if body.get_name() == "Player":
		emit_signal("player_entered")
		queue_free()
