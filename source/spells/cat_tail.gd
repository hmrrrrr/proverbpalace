extends TileModifierSpell
class_name CatTail

func set_status_tooltips():
	status_tooltips = [{status = TileStatus.ASH}]

const VOWELS := ['a','e','i','o','u']

var chamber = []

const Y_CHANCE := .1
const PLANT_CHANCE := 0.1
const FAGGOT_CHANCE := .003

var IS_THIS_THE_PLANT_OR_NAH := false
const PAW_STAMP_EFFECT = preload("res://mods/proverbpalace/source/spells/paw_stamp_effect.tscn")

const SOUNDS = {
	FUCKING_MINECRAFT_SOUND_OK_GET_OFF_MY_BACK = preload("res://mods/proverbpalace/sounds/fucking_minecraft_sound_ok_get_off_my_back.mp3"),
	STOCK_EXPLOSION = preload("res://mods/proverbpalace/sounds/StockExplosion.mp3"),
	KITTYTILE = preload("res://mods/proverbpalace/sounds/tiles/kittytile.wav"),
}

func _first_spawn(is_transform: = false) -> void :
	IS_THIS_THE_PLANT_OR_NAH = rng.spell.randf() < PLANT_CHANCE
	
	frame_updated.emit()
	
	super._first_spawn(is_transform)

func get_tooltip_context():
	return {the_plant=IS_THIS_THE_PLANT_OR_NAH}

func get_hv_frames() -> Vector2i:
	return Vector2i(2, 1)

func get_frame() -> int:
	return 1 if IS_THIS_THE_PLANT_OR_NAH else 0

func get_save_data():
	var save = super.get_save_data()
	save["IS_THIS_THE_PLANT_OR_NAH"] = IS_THIS_THE_PLANT_OR_NAH
	save["chamber"] = chamber
	return save

func load_save_data(save):
	super.load_save_data(save)
	IS_THIS_THE_PLANT_OR_NAH = save.IS_THIS_THE_PLANT_OR_NAH
	frame_updated.emit()
	chamber = save.chamber

func load_chamber():
	chamber = []
	chamber.append_array(VOWELS)
	chamber.append_array(VOWELS)
	rng.spell.shuffle(chamber)
	
func make_kitty_ash(tile: Tile, should_be_kitty: bool, is_tooltip := false) -> void:
	tile.add_status(TileStatus.ASH,{kitty=should_be_kitty})
	if should_be_kitty and !is_tooltip:
		AudioManager.play_sound(
			SOUNDS.KITTYTILE,
			randf_range(1.3,1.9),
			0.13
		)
	
func change_to_ash_vowel(tile: Tile, is_right: bool, do_faggot_easter_egg: bool) -> void:
	if chamber.is_empty():
		load_chamber()
	var chosen_vowel: String = chamber.pop_back()
	
	if (rng.spell.randf() < Y_CHANCE) and is_right:
		chosen_vowel = "y"
	
	if do_faggot_easter_egg:
		if is_right:
			chosen_vowel = "ot"
		else:
			chosen_vowel = "fa"
	
	tile.set_face(chosen_vowel)
	make_kitty_ash(tile,do_faggot_easter_egg)
	

func do_paw_stamp_effect(tile: Tile, lerp_t: float, faggotron: bool = false) -> void:
	var effect := PAW_STAMP_EFFECT.instantiate() as PawStampEffect
	
	effect.should_be_plant = IS_THIS_THE_PLANT_OR_NAH
	
	tile.tile_sprite.add_child(effect)
	effect.global_position = tile.global_position
	
	var correct_sound = SOUNDS.FUCKING_MINECRAFT_SOUND_OK_GET_OFF_MY_BACK if IS_THIS_THE_PLANT_OR_NAH else Sounds.STATUS_SOUNDS[TileStatus.CANDY]
	var vol := 1.
	if faggotron:
		correct_sound = SOUNDS.STOCK_EXPLOSION
		vol = .2
	await effect.apply
	AudioManager.play_sound(
		correct_sound,
		lerp(0.85,1.3,lerp_t),vol
	)
	tile.animation.play("bounce")
	

func is_tile_selectable(tile: Tile) -> bool:
	return !tile.has_status(TileStatus.ASH) 

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	if is_preview:
		tile.set_face("w")
		make_kitty_ash(tile,true,true)
	else:
		
		
		var SHOULD_DO_FAGGOT_EASTER_EGG := rng.spell.randf() < FAGGOT_CHANCE
		
		tile.add_poofcloud(Globals.COLORS.ASH)
		var t := 0.
		for vec in [Vector2i.LEFT,Vector2i.ZERO,Vector2i.RIGHT]:
			var neighbor: Tile
			if vec == Vector2i.ZERO:
				neighbor = tile
			else:
				neighbor = tile.get_board_neighbor(vec)
			
			if vec == Vector2i.ZERO:
				(func():
					await do_paw_stamp_effect(tile,t,SHOULD_DO_FAGGOT_EASTER_EGG)
					tile.set_face("w" if !SHOULD_DO_FAGGOT_EASTER_EGG else "gg")
					make_kitty_ash(tile,true)
				).call()
			else:
				(func():
					if neighbor:
						await do_paw_stamp_effect(neighbor,t,SHOULD_DO_FAGGOT_EASTER_EGG)
						change_to_ash_vowel(neighbor, vec == Vector2i.RIGHT, SHOULD_DO_FAGGOT_EASTER_EGG)
				).call()
			await Game.timeout(0.17)
			t += .5
