extends Spell
class_name Datamosh

const CHARS_BY_RARITY = """\
qjxzwkvfybhgmp9udcl5otnrais8e24367\
"""
var current_frame := 0


func _first_spawn(is_transform: = false) -> void:
	super(is_transform)
	if charge_character in "e24" or has_curse(CURSE.ESOTERIC):
		max_charge = 1

func set_status_tooltips():
	status_tooltips = [TileStatus.CURSED,TileEffect.NUMBER]

func get_hv_frames() -> Vector2i:
	return Vector2i(7,1)

func get_frame() -> int:
	
	
	current_frame = (current_frame + randi_range(1,2))%3
	if randf() < .13:
		current_frame = randi_range(3,5)
	return current_frame

func has_valid_word() -> bool:
	var words: WordList = word_builder.get_words()
	return word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1

func get_target_tiles():
	return word_builder.tiles.duplicate()

const SOUNDS = {
	DATAMOSH=preload("res://mods/proverbpalace/sounds/datamosh.wav"),
	DATAMOSH_VAR1=preload("res://mods/proverbpalace/sounds/datamosh1.wav"),
	DATAMOSH_VAR2=preload("res://mods/proverbpalace/sounds/datamosh2.wav"),
	DATAMOSH_VAR3=preload("res://mods/proverbpalace/sounds/datamosh3.wav"),
	DATAMOSH_VAR4=preload("res://mods/proverbpalace/sounds/datamosh4.wav"),
	KITTYTILE = preload("res://mods/proverbpalace/sounds/tiles/kittytile.wav")
}
const DATAMOSH_EFFECT = preload("res://mods/proverbpalace/source/datamosh/datamosh_effect_instance.tscn")


static func get_corresponding_numbers(face: String) -> String:
	
	var new_face = ""
	for letter in face:
		var found = false
		for number in Letters.NUMPAD_CHARACTERS.keys():
			var corresponding_letters = Letters.NUMPAD_CHARACTERS[number]
			if letter in corresponding_letters:
				new_face += (number)
				found = true
		
		if !found:
			new_face += letter
	
	return new_face

static func set_tile_face_to_corresponding_numbers(tile: Tile):
	if len(tile.tile_face.slashed_faces) != 0:
		var faces = tile.tile_face.slashed_faces.duplicate()
		for i in range(len(faces)):
			faces[i] = get_corresponding_numbers(faces[i])
		tile.set_slashed(faces)
	else:
		tile.set_face(get_corresponding_numbers(tile.face))

func _use():
	if not has_valid_word():
		_end_use()
		return

	AudioManager.play_sound(SOUNDS.DATAMOSH)

	var apply_to = get_target_tiles()
	rng.spell.shuffle(apply_to)
	var last_effect: GenericTileEffect
	for tile: Tile in apply_to:
		if is_tile_selectable(tile):
			
			var is_kitty: bool = tile.has_status(TileStatus.ASH)
			if is_kitty:
				for status in tile.get_statuses():
					if status.id == TileStatus.ASH or status.id == TileStatus.CURSED:
						is_kitty = status.get("kitty")
			
			var do_curse = !tile.has_status(TileStatus.CRIT)
			
			var inst := DATAMOSH_EFFECT.instantiate() as GenericTileEffect
			inst.do_play_sound = func():
				if is_kitty:
					AudioManager.play_sound(SOUNDS.KITTYTILE,0.55,.1)
				else:
					AudioManager.play_sound(
						SOUNDS["DATAMOSH_VAR%d"%randi_range(1,4)],randf_range(0.5,1.5)
					)
				set_tile_face_to_corresponding_numbers(tile)
			inst.frame_coords = tile.tile_sprite.base_sprite.frame_coords
			tile.tile_sprite.add_child(inst)
			inst.atlas = tile.tile_sprite.base_sprite.texture
			inst.dont_change = !do_curse
			inst.bounce.connect(
				func():
					tile.animation.play("shake"))
			await Game.timeout(0.05)
			
			if do_curse:
				tile.add_status(TileStatus.CURSED,{kitty=is_kitty})
				
				
				
			last_effect = inst
		else:
			tile.animation.play("shake")
	
	await last_effect.effect_finished
	_post_use()




func is_usable():
	return super.is_usable() and has_valid_word() and any_tile_selectable(get_target_tiles())


func is_tile_selectable(tile: Tile) -> bool:
	if randf() < .3:
		frame_updated.emit()
	return tile.has_face()
