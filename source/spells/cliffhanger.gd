extends TileModifierSpell


func set_status_tooltips():
	status_tooltips = [TileStatus.CRIT, "epsilon", TileStatus.PERIOD]

func should_deprioritize_tile(tile: Tile):
	if tile.has_any_effect(
		[
			TileEffect.SHIMMERING,
			TileStatus.MYSTERY,
			TileStatus.PERIOD,
			TileStatus.CAPITAL,
			TileStatus.HOLE
		]
	):
		return true
	
	if tile.has_effect(TileEffect.POSITIVE_FACE):
		return false
	
	var single_face: String = tile.face
	
	match len(single_face):
		1:
			if single_face in Letters.ENDING_LETTERS:
				return false
		2:
			if single_face in Letters.ENDING_BIGRAMS:
				return false
		3:
			if single_face in Trigrams.ENDING_TRIGRAMS:
				return false
	
	return true

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	tile.randomize_if_faceless(rng.spell, is_preview)
	tile.add_status(TileStatus.CRIT)
	tile.set_face(ProverbPalaceTileManager.EPSILON)

	if is_preview:
		return

	tile.add_poofcloud(Globals.COLORS.SMOKE)
	
	
	var bleed_left = 1
	var neighbor_tiles = tile.get_board_neighbors()
	
	if len(neighbor_tiles) == 0:
		return
	
	var bad_tiles = neighbor_tiles.filter(func(t: Tile): return should_deprioritize_tile(t))
	var good_tiles = neighbor_tiles.filter(func(t: Tile): return !should_deprioritize_tile(t))
	
	rng.spell.shuffle(good_tiles)
	rng.spell.shuffle(bad_tiles)
	
	neighbor_tiles = good_tiles + bad_tiles
	
	await Game.timeout(0.06)
	
	tile.add_status(TileStatus.PERIOD)
	tile.animation.play("shake")
	
	await Game.timeout(0.06)
	
	var target: Tile = neighbor_tiles[0]
	AudioManager.play_sound(Sounds.TILE.LINKED,1.2)
	target.animation.play("shake")
	
	target.add_status(TileStatus.PERIOD)

func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable()
		and not tile.has_harmful_status()
		and not tile.has_any_effect([
			TileEffect.SHIMMERING, TileStatus.MYSTERY, TileStatus.CAPITAL, TileStatus.PERIOD
			])
	)
