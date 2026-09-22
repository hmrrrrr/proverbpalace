@tool
extends Node

@onready var editor_preview: Sprite2D = $EditorPreview
@onready var parent = get_parent()

@export var squish_scale := Vector2.ONE : set=_set_squish_scale

var target: Node : get=_get_target

func _get_target() -> Node:
	if Engine.is_editor_hint():
		return editor_preview
	return parent

func _set_squish_scale(amt: Vector2):
	squish_scale = amt
	if target:
		target.scale = squish_scale

func _ready() -> void:
	if !Engine.is_editor_hint():
		editor_preview.hide()
		editor_preview.queue_free()


func _on_anim_player_animation_stopped(anim_name: StringName) -> void:
	queue_free()
