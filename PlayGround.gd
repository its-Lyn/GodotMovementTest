extends Node2D

var respawn_pos = Vector2(40.0, 400.0)

func _on_death_area_body_entered(body):
	body.position = respawn_pos
