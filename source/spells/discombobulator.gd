extends Spell
const GLITCH_REDACT_EFFECT = preload("res://mods/proverbpalace/source/effects/glitch_redact_effect.tscn")

func get_spells_count() -> int:
	var spells = player.spell_container.get_spells().filter(is_spell_valid_target)
	return len(spells)
#
#func has_valid_word() -> bool:
	#var words: WordList = word_builder.get_words()
	#return word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1
const DATAMOSH_SOUND = preload("res://mods/proverbpalace/sounds/datamosh.wav")


func is_spell_valid_target(spell: Spell) -> bool:
	return (spell.spell_data.charge_category not in CHARGE_CATEGORIES.LIMITED) and spell.max_charge >= 1

#func get_spelled_word_raw() -> String:
	#var words: WordList = word_builder.get_words()
	#if !has_valid_word():
		#return ""
	#var faces := words.sub_lists[0].all_faces
	#
	#var out := ""
	#for tile: Tile in word_builder.tiles:
		#for ch in tile.face:
			#if ch in Letters.ALPHABET + Letters.NUMBERS:
				#out+=(ch)
			#elif ch == "/":
				#var rngdupe: RNG = rng.spell.duplicate()
				#out+=(rngdupe.pick_random(tile.tile_face.slashed_faces)[0])
			#else:
				#return ""
	#if len(out) != get_other_spells_count():
		#return ""
	#return out

#func is_usable():
	#return super.is_usable() and get_spelled_word_raw() != ""

const VALID_CHARACTERS = Letters.ALPHABET + Letters.NUMBERS

func is_tile_valid(tile: Tile):
	return !(tile.has_any_effect([TileEffect.SHIMMERING])) and (!tile.has_harmful_status()) and (len(tile.face) == 1) and (tile.face in VALID_CHARACTERS) and tile.has_face()



func _use():
	var spells: Array[Spell] = player.spell_container.get_spells().filter(is_spell_valid_target)
	var spell_count := get_spells_count()
	var row_coords = tile_board.get_row_coords()
	var rows = []
	for row_coord in row_coords:
		var r = tile_board.get_row(row_coord)
		if len(r) < spell_count:
			continue
		var i = 0
		var j = false
		for tile in r:
			if !is_tile_valid(tile) and i < spell_count:
				j = true
			i += 1
		if j:
			continue
		rows.append(row_coord)
	
	if len(rows) == 0:
		_end_use()
		return
	var row = rng.spell.pick_random(rows)
	var target_tiles = get_tiles({
		rows = [row], 
		sorted = true, 
	})
	
	
	if target_tiles.is_empty() or len(target_tiles) < spell_count:
		_end_use()
		return
	
	target_tiles = target_tiles.slice(0,spell_count)
	
	var effects: Array[GlitchRedactEffect] = []
	
	for i in range(spell_count):
		var spell := spells[i]
		var tile: Tile = target_tiles[i]
		var letter = tile.face
		tile.animation.play("bounce")
		spell.charge_character = letter
		var new_data = SpellData.new()
		new_data.id = spell.spell_data.id
		new_data.mod = spell.spell_data.mod
		new_data.load_data()
		new_data.load_script()
		new_data.charge_category = CHARGE_CATEGORIES.COMMON
		spell.spell_data = new_data
		if spell.charge_container != null:
			spell.charge_container.update_charge_character(true)
			
			for charge_tile: SpellChargeTile in spell.charge_container.get_tiles():
				var inst := GLITCH_REDACT_EFFECT.instantiate() as GlitchRedactEffect
				charge_tile.charge_face.add_child(inst)
				effects.append(inst)
			AudioManager.play_sound(DATAMOSH_SOUND,1.6)
			
			await Game.timeout(0.08)
	
	(func (): 
		await Game.timeout(.45)
		for effect in effects:
			effect.queue_free()
		
		
		).call()
	await tile_board.remove_tiles(target_tiles,{
		interval = 0.08,
		poof_blend = Globals.COLORS.ALIUM_BLOOD, 
		restock = true, 
		tile_color = true, 
	})
	_post_use()
