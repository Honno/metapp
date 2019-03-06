extends Area2D

signal player_death

func _on_DeathTrigger_body_entered(body):
	if body.get_name() == "Player":
		emit_signal("player_death")