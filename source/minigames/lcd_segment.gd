class_name LCDSegment extends Node2D


signal state_changed(is_reverted)

var base_letter = ""
var state = false
var original_state = false

@onready var sprite: Sprite2D = $Sprite
@onready var button: Button = $Button
@onready var hover_handler: HoverHandler = %HoverHandler


func set_state(new_state, initial = false):
	if new_state == state:
		return

	state = new_state

	if state: sprite.frame = 1
	else: sprite.frame = 0

	if initial:
		original_state = new_state
	else:
		state_changed.emit()


func set_disabled(disabled: bool) -> void :
	button.disabled = disabled
	hover_handler.set_disabled(disabled)


func _on_button_pressed():
	AudioManager.play_sound(Sounds.UI.TILE_CLICK,1.2)
	set_state( not state)
