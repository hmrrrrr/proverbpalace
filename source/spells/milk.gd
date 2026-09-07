extends Spell
class_name Milk

func set_status_tooltips():
	status_tooltips = [{status = TileStatus.ENHANCED, wooden = true}]

func has_valid_word() -> bool:
	var words: WordList = word_builder.get_words()
	var repeat_word := word_builder.get_repeat_word(words)
	
	var valid_by_containing := false
	if repeat_word == "" and words.words.size() == 1:
		var currently_spelled_word := words.words[0]
		var run_used_words: Array = main.run_stats.get_words()
		for word in run_used_words:
			if currently_spelled_word in word:
				valid_by_containing = true
	
	return (repeat_word != "" or valid_by_containing) and word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1

func get_target_tiles() -> Array[Tile]:
	return word_builder.tiles.duplicate()

const SOUNDS = {
	MILKSPILL = preload("res://mods/proverbpalace/sounds/milkspill.wav")
	
}
const MILK_EFFECT = preload("res://mods/proverbpalace/source/spells/milk/milk_effect_instance.tscn")

func _ready() -> void:
	charge_updated.connect(
		func():
			frame_updated.emit()
	)

func _use():
	if not has_valid_word():
		_end_use()
		return

	AudioManager.play_sound(SOUNDS.MILKSPILL)

	var apply_to = get_target_tiles()
	#rng.spell.shuffle(apply_to)
	var last_effect: GenericTileEffect
	for tile : Tile in apply_to:
		if is_tile_selectable(tile):
			var do_milk = (!tile.has_status(TileStatus.CRIT)) and (tile.type == TileType.DAMAGE)
			#tile.add_poofcloud(tile.get_color())
			var inst := MILK_EFFECT.instantiate() as GenericTileEffect
			inst.do_play_sound = func():
				#AudioManager.play_sound(
					#SOUNDS["DATAMOSH_VAR%d"%randi_range(1,4)],randf_range(0.5,1.5)
				#)
				pass
			inst.frame_coords = tile.tile_sprite.base_sprite.frame_coords
			tile.tile_sprite.add_child(inst)
			inst.atlas = tile.tile_sprite.base_sprite.texture
			inst.dont_change = !do_milk
			inst.bounce.connect(
				func():
					if !do_milk:
						#tile.animation.play("shake")
						pass
					)
						
			await Game.timeout(0.015)
			if do_milk:
				tile.add_status(TileStatus.ENHANCED)
			last_effect = inst
		else:
			tile.animation.play("shake")
	
	await last_effect.effect_finished
	_post_use()
	
	frame_updated.emit()

func has_any_wood_tile(tiles:Array[Tile]) -> bool:
	for tile in tiles:
		if tile.type == TileType.DAMAGE:
			return true
	return false
	

func any_wood_tile_not_ivory(tiles: Array[Tile]) -> bool:
	for tile in tiles:
		if tile.type == TileType.DAMAGE:
			if !tile.has_status(TileStatus.ENHANCED):
				return true
	return false

func is_usable():
	var tiles := get_target_tiles()
	return (
		super.is_usable() and
		has_valid_word() and
		any_tile_selectable(tiles) and 
		any_wood_tile_not_ivory(tiles) and
		has_any_wood_tile(tiles)
	)


func get_hv_frames() -> Vector2i:
	return Vector2i(2, 1)


func get_frame() -> int:
	return 0 if charge == 0 else 1


func is_tile_selectable(tile: Tile) -> bool:
	return true
