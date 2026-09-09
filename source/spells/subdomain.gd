extends Spell


func set_status_tooltips():
	status_tooltips = [TileStatus.PERIOD,TileStatus.CRIT]



func _use():
	if not has_valid_word():
		_end_use()
		return

	AudioManager.play_sound(Sounds.SPELLS.SPRAY_SHORT)

	var apply_to := get_target_tiles()
	
	rng.spell.shuffle(apply_to)
	
	const HARMFUL_DEPRIO_CONSISTENCY: int = 10
	
	#random sort that deprioritizes harmful statuses (with high consistency) and crits (with 100% consistency)
	apply_to.sort_custom(
		func(a: Tile, b: Tile) -> bool:
			var harmful_a := a.has_harmful_status()
			var harmful_b := b.has_harmful_status()
			
			var crit_a := a.has_status(TileStatus.CRIT)
			var crit_b := b.has_status(TileStatus.CRIT)
			
			if crit_a and !crit_b:
				return false
			if crit_b and !crit_a:
				return true
			
			if harmful_a and !harmful_b:
				return rng.spell.randi()%HARMFUL_DEPRIO_CONSISTENCY == 0
			if harmful_b and !harmful_a:
				return rng.spell.randi()%HARMFUL_DEPRIO_CONSISTENCY != 0
			
			return rng.spell.randi()%2 == 0
			)
	
	
	apply_to = apply_to.slice(0, 2)
	
	for tile in apply_to:
		tile.animation.play("pressed")
		tile.add_status(TileStatus.CRIT)
		tile.add_status(TileStatus.PERIOD)
	
	_post_use()


func has_valid_word() -> bool:
	var words: WordList = word_builder.get_words()
	return word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1 and word_builder.tiles.size() > 1


func get_target_tiles() -> Array[Tile]:
	return word_builder.tiles.duplicate()


func is_usable():
	return super.is_usable() and has_valid_word() and any_tile_selectable(get_target_tiles())


func is_tile_selectable(tile: Tile) -> bool:
	return !tile.has_status(TileStatus.CRIT) and tile.has_face() and !tile.has_status(TileStatus.PERIOD)
