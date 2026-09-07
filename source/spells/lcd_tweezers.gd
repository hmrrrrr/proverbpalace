extends Spell


var minigame_scene = load("res://mods/proverbpalace/source/minigames/7seg_minigame.tscn")
var minigame: SevenSegMinigame = null

const LIBRARY = preload("res://mods/proverbpalace/source/7seg/library.res")

var faking_out := true

func on_hover():
	if player.is_using_spell():
		return

	switch_state()

func switch_state():
	if faking_out:
		faking_out = false
		shake.emit()
		_update_state()

func get_tooltip_context():
	return {fakeout = faking_out}

func _update_state():
	frame_updated.emit()
	description_updated.emit()

func get_hv_frames() -> Vector2i:
	return Vector2i(2, 1)


func get_frame() -> int:
	return 0 if faking_out else 1
	
func _use():
	var tile = await get_selection()

	if tile == null:
		_end_use()
		return

	start_minigame(tile)
	await minigame.finished

	var new_face: String = minigame.get_current_letter()
	await end_minigame()

	if new_face == "" or new_face == tile.face:
		_end_use()
		return

	if not (new_face in Letters.ALPHABET or new_face in Letters.NUMBERS):
		tile.add_status(TileStatus.ASH)

	tile.set_face(new_face)
	tile.add_poofcloud(Globals.COLORS.INK_BLACK)
	tile.play_tile_sound()

	_post_use()


func is_tile_selectable(tile: Tile) -> bool:
	return (len(tile.face) == 1 and len(tile.faces) == 1 and not tile.has_effect(TileEffect.SLASHED)) and not tile.has_status(TileStatus.MYSTERY) and (LIBRARY.find_letter(tile.face) != null)


func start_minigame(tile: Tile):
	minigame = minigame_scene.instantiate()
	minigame.start()
	minigame.set_tile(tile)
	minigame.appear()


func end_minigame():
	await minigame.disappear()
	minigame.end()
