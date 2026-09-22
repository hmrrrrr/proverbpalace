extends Node2D
class_name CounterPunchEffect

signal punch

func _on_anim_player_animation_stopped(_anim_name: StringName) -> void:
	queue_free()


func _on_anim_player_event_emitted(event_name: String) -> void:
	if event_name == "punch": punch.emit()
