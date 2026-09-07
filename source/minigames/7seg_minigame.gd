class_name SevenSegMinigame extends Minigame


var original_letter: String = ""
var editing_tile: Tile
var preview_tile_a: Tile
var preview_tile_b: Tile
var lcd_segments: Array[LCDSegment] = []
var segment_scene: PackedScene = load("res://mods/proverbpalace/source/minigames/lcd_segment.tscn")

const library := preload("res://mods/proverbpalace/source/7seg/library.res")
const LCD_ARROW = preload("res://mods/proverbpalace/arte/minigames/lcd_arrow.png")
const DNA_ARROW = preload("res://arte/minigames/dna_arrow.png")

@onready var board: Sprite2D = %Board
@onready var turns_label: Label = %TurnsLabel
@onready var addict_timer: Label = %AddictTimer

@onready var reset_sprite: Sprite2D = %ResetSprite
@onready var reset_button: Button = %ResetButton
@onready var reset_hover_handler: HoverHandler = %ResetHoverHandler

@onready var confirm_sprite: Sprite2D = %ConfirmSprite
@onready var confirm_tooltip = %ConfirmButtonTooltip

@onready var anim_player = %AnimPlayer
@onready var arrow_sprite: Sprite2D = Game.main.spell_banner.tile_conversion.find_child("Sprite2D")


const SEGMENT_POSITIONS = [
	Vector2(28,14),
	Vector2(42,28),
	Vector2(42,56),
	Vector2(28,70),
	Vector2(14,56),
	Vector2(14,28),
	Vector2(28,42),
]

func _ready():
	
	const ROTATED_SEGMENTS = [0,3,6]
	
	var buttons: Array[Button] = []
	for i in range(7):
		var lcd_segment: LCDSegment = segment_scene.instantiate()

		board.add_child(lcd_segment)
		lcd_segments.append(lcd_segment)
		buttons.append(lcd_segment.button)

		lcd_segment.position = SEGMENT_POSITIONS[i] - Vector2(56/2,88/2)
		lcd_segment.state_changed.connect(update_state)
		
		if i in ROTATED_SEGMENTS:
			lcd_segment.rotation = PI/2.
			lcd_segment.hover_handler.hovered_position = lcd_segment.hover_handler.hovered_position.rotated(
				-PI/2.
			)
			lcd_segment.hover_handler.pressed_position = lcd_segment.hover_handler.pressed_position.rotated(
				-PI/2.
			)
	
	arrow_sprite.texture = LCD_ARROW
	
	Util.set_control_grid_focus(
		[
			[buttons[5],buttons[0],buttons[1]],
			[buttons[5],buttons[6],buttons[1]],
			[buttons[4],buttons[3],buttons[2]],
		], true, false)


func set_tile(tile: Tile) -> void :
	editing_tile = tile
	if tile.type == Tile.TileType.DAMAGE:
		board.frame = 0
	else:
		board.frame = 1

	set_mosaic(tile.face)


func set_mosaic(letter: String):
	original_letter = letter

	var sevseg_character: SevenSegCharacter = library.find_letter(letter)

	for i in range(7):
		var seg = lcd_segments[i]
		var state = sevseg_character.segments[i]

		if state:
			seg.set_state(true, true)
		else:
			seg.set_state(false, true)

	update_state()


func get_current_letter() -> String:
	var states = [false,false,false,false,false,false,false]
	var i = 0
	for seg in lcd_segments:
		if seg.state:
			states[i] = true
		i += 1
	
	if SevenSegCharacter.get_segment_bits(states) == library.find_letter(original_letter).get_bits():
		return original_letter
	return library.find_best_fit_character(states,true)


func appear(instant: = false) -> void :
	addict_timer.visible = Game.player.id == Globals.CHARACTERS.ADDICT

	await Game.tile_board.slide_out(instant)
	await Game.conditional_timeout(0.16, instant)
	await anim_player.play_until_finished("appear", instant)

	preview_tile_a = Game.tile_board.create_preview_tile(editing_tile)
	preview_tile_b = Game.tile_board.create_preview_tile(editing_tile)
	Game.main.spell_banner.set_tiles(preview_tile_a, preview_tile_b)


func disappear(instant: = false) -> void :
	await anim_player.play_until_finished("disappear", instant)
	await Game.conditional_timeout(0.16, instant)
	await Game.tile_board.slide_in(instant)
	arrow_sprite.texture = DNA_ARROW


func cancel() -> void :
	AudioManager.play_sound(Sounds.UI.WORD_SUBMIT)
	finished.emit()


func confirm() -> void :
	AudioManager.play_sound(Sounds.UI.WORD_SUBMIT)
	finished.emit()


func update_state() -> void :
	var moves_remaining: = 2
	for seg in lcd_segments:
		seg.set_disabled(false)
		if seg.state != seg.original_state:
			moves_remaining -= 1

	if moves_remaining == 0:
		for seg in lcd_segments:
			seg.set_disabled(seg.state == seg.original_state)

	turns_label.text = str(moves_remaining) + "/2"

	reset_button.disabled = moves_remaining == 2
	reset_sprite.frame = 1 if reset_button.disabled else 2
	reset_hover_handler.set_disabled(reset_button.disabled)

	var current_letter: = get_current_letter()

	if preview_tile_b != null:
		if current_letter == "":
			preview_tile_b.set_face("?")
		else:
			preview_tile_b.set_face(current_letter)
	
		if current_letter in Letters.ALPHABET or current_letter in Letters.NUMBERS or current_letter == "":
			preview_tile_b.remove_status(Tile.TileStatus.ASH)
		else:
			preview_tile_b.add_status(Tile.TileStatus.ASH)
		

	var confirmable: bool = (
		moves_remaining != 2
		and current_letter != ""
		and current_letter != original_letter
	)

	confirm_sprite.frame = 4 if confirmable else 3
	confirm_tooltip.context = {confirmable = confirmable}


func handles_right_stick() -> bool:
	return false


func has_left_stick_targeting() -> bool:
	return true


func get_left_stick_center() -> Vector2:
	return global_position


func get_left_stick_focus_holder() -> Control:
	return lcd_segments[6].button


func get_left_stick_targets() -> Dictionary[Control, Vector2]:
	var targets: Dictionary[Control, Vector2]
	for seg in lcd_segments:
		targets[seg.button] = seg.global_position

	return targets


func get_default_focus() -> Control:
	return lcd_segments[0].button


func get_addict_timer() -> Label:
	return addict_timer


func _on_confirm_button_pressed() -> void :
	confirm()


func _on_reset_button_pressed() -> void :
	AudioManager.play_sound(Sounds.UI.MENU_BUTTON)
	set_mosaic(original_letter)
	update_state()
