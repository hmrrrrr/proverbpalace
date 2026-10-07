extends BattleUnitSprite

@onready var attendant_real_sprite: Node2D = $ViewportSprite/SubViewport/AttendantReal

@onready var indices = range(len(
	attendant_real_sprite.segments
))


func _on_thirds_beat_player_interval_beat() -> void:
	attendant_real_sprite.segments[indices[0]].animate_cycle()

func _on_half_beat_player_interval_beat() -> void:
	attendant_real_sprite.segments[indices[1]].animate_cycle()


func _on_sixth_beat_player_interval_beat() -> void:
	attendant_real_sprite.segments[indices[2]].animate_cycle()
	await Game.timeout(.12)
	indices.shuffle()
