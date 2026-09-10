extends Spell

func is_coop_enabled() -> bool:
	return ModLoader.mods.any(func (mod:Mod)->bool:return mod.id=="co-op")

const FIBONACCI_NUMBERS = [0, 1, 1, 2, 3, 5, 8, 13, 21]
const COW_BIGRAMS: Dictionary[String, String] = {
	"a": "at", 
	"b": "bl", 
	"c": "ch", 
	"d": "di", 
	"e": "er", 
	"f": "fl", 
	"g": "gr", 
	"h": "he", 
	"i": "ie", 
	"j": "ju", 
	"k": "kn", 
	"l": "ld", 
	"m": "mp", 
	"n": "ng", 
	"o": "or", 
	"p": "ph", 
	"q": "qu", 
	"r": "rt", 
	"s": "sh", 
	"t": "tr", 
	"u": "un", 
	"v": "ve", 
	"w": "wh", 
	"x": "xp", 
	"y": "yp", 
	"z": "ze", 
}

var sections: Dictionary[String, Dictionary] = {}

var country_code: String = Steam.getIPCountry().to_lower()

func _ready() -> void:
	randomize_sections(rng.spell)

func _use():
	randomize_sections(rng.spell)
	_end_use()

func get_save_data():
	var save = super()
	save.country_code = country_code
	return save

func load_save_data(save):
	super(save)
	country_code = save.country_code

func get_random_word_category(bubble_rng: RNG):
	return bubble_rng.pick_random(Globals.WORD_CATEGORY_FLAGS.keys())

func letter_opener_tile_launch(tile: Tile):
	
	tile.add_poofcloud(Globals.COLORS.SMOKE, Globals.COLORS.BLEND_SMOKE)


	var bounce_offset: = randf_range(32, 72)
	var direction: = randi_range(0, 1)
	var direction_sign: = -1 if direction == 0 else 1
	var dest = Vector2(tile.global_position.x + bounce_offset * direction_sign, 290)
	var projectile: = tile.launch(tile.global_position, dest, 32, Vector2i.MIN, 1200, true, false, false)
	projectile.look_at_direction = false
	projectile.angular_velocity = PI * 10
	projectile.angular_deceleration = PI * 18
	projectile.decelerate_to = PI * 2
	
	await tile_board.remove_tile(tile, {
		delete_tiles = false, 
		settle = true, 
		restock = true, 
	})
	
	
func randomize_sections(bubble_rng: RNG):
	var random_category_name = get_random_word_category(bubble_rng)
	var random_category = Globals.WORD_CATEGORY_FLAGS[random_category_name]

	var random_neg_status = bubble_rng.pick_random(
		[
			TileStatus.BRUISE,TileStatus.ASH,TileStatus.CAPITAL,TileStatus.GUNK
		]
	)
	var random_defensive_status = bubble_rng.pick_random(
		[
			TileStatus.FROZEN, TileStatus.CANDY
		]
	)
	
	const DEFAULT_SECTION = {
		condition = false,
		read_only = false,
		params = [],
		output = [],
		run = null
	}
	
	sections = {
		"swap_tile_type": {
			params = ["tile"],
			output = ["tile"],
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				tile.set_type(TileType.DAMAGE if tile.is_type(TileType.DEFENSE) else TileType.DEFENSE)
				return {tile = tile}
	},
		"get_spelled_word": {
			params = [],
			output = ["word"],
			condition = true,
			read_only = true,
			run = func(_params: Dictionary):
				if !(word_builder.can_submit_tiles() and word_builder.can_submit_words(word_builder.words_list)):
					return false
				var first_word = word_builder.words_list.get_first_word()
				if first_word:
					return {word = first_word}
				return false
	},
		"word_is_in_category": {
			params = ["word"],
			output = ["word"],
			condition = true,
			read_only = true,
			context = {category = random_category_name},
			run = func(params: Dictionary):
				var word: WordList = params.word
				if WordUtility.word_list_has_flag(word, random_category) and word.sub_lists.size() == 1:
					return {word=word}
				return false
	},
		"tile_is_faceless": {
			params = ["tile"],
			output = ["tile"],
			condition = true,
			read_only = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				if !tile.has_face():
					return {tile=tile}
				return false
	},
		"pick_random_tile": {
			params = [],
			output = ["tile"],
			read_only = true,
			run = func(_params: Dictionary):
				var tiles: Array[Tile] = tile_board.get_tiles({amount = 1})
				if len(tiles) == 0:
					return false
				return {
					tile = tiles[0]
				}
	},
		"has_fib_hp": {
			params = [],
			output = [],
			condition = true,
			read_only = true,
			run = func(_params: Dictionary):
				return player.health in FIBONACCI_NUMBERS
	},
		"get_country_code": {
			params = [],
			output = ["ngram"],
			read_only = true,
			run = func(_params: Dictionary):
				if len(country_code) == 2:
					return {ngram = country_code}
				return {ngram = "uh"}
	},
		"place_ngram": {
			params = ["ngram", "tile"],
			output = ["tile"],
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				var ngram: String = params.ngram
				tile.set_face(ngram)
				return {tile = tile}
	},
		"place_ngram_slashed": {
			params = ["ngram", "tile"],
			output = ["tile"],
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				var ngram: String = params.ngram
				tile.set_slashed(ngram.split())
				return {tile = tile}
	},
		"append_cow_bigram": {
			params = ["tile"],
			output = ["tile"],
			condition = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				if !tile.is_single_letter(false,false):
					return false
				if tile.face not in COW_BIGRAMS:
					return false
				tile.set_face(COW_BIGRAMS[tile.face])
				return {tile=tile}
	},
		"tile_is_status": {
			params = ["tile", "status"],
			output = ["tile"],
			condition = true,
			read_only = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				var status: String = params.status
				if tile.has_status(status):
					return {tile = tile}
				return false
	},
		"turn_tile_to_status": {
			params = ["tile", "status"],
			output = ["tile"],
			condition = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				var status: String = params.status
				if tile.has_status(status):
					return false
				tile.add_status(status)
				return {tile = tile}
	},
		"get_spelled_status": {
			params = ["word"],
			output = ["word","status"],
			condition = true,
			read_only = true,
			run = func(params: Dictionary):
				var word: WordList = params.word
				if word.sub_lists.size() != 1:
					return false
				var word_string: String = word.get_first_word()
				if word_string in TileStatus.values():
					return {status = word_string, word = word}
				return false
	},
		"face_all_from_back_half_of_alphabet": {
			params = ["tile"],
			output = ["tile"],
			condition = true,
			read_only = true,
			
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				var alpha_second_half = Letters.ALPHABET.slice(13)
				if !tile.has_single_face(99):
					return false
				var face := tile.face
				for let in face:
					if let not in alpha_second_half:
						return false
				return {tile = tile}
	},
		"make_capital_wildcard": {
			params = ["tile"],
			output = [],
			condition = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				if tile.only_face_is("*") and tile.has_status(TileStatus.CAPITAL):
					return false
				
				tile.set_face("*")
				tile.add_status(TileStatus.CAPITAL)
				return true
	},
		"get_random_negative_status": {
			params = [],
			output = ["status"],
			read_only = true,
			run = func(_params: Dictionary):
				return {status=random_neg_status}
	},
		"get_random_defensive_status": {
			params = [],
			output = ["status"],
			read_only = true,
			run = func(_params: Dictionary):
				return {status=random_defensive_status}
	},
		"tile_is_single_number": {
			params = ["tile"],
			output = ["tile"],
			condition = true,
			read_only = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				if len(tile.get_numbers()) == len(tile.face) and tile.has_single_face(1):
					return {tile=tile}
				return false
	},
		"remove_tile": {
			params = ["tile"],
			output = [],
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				await letter_opener_tile_launch(tile)
				return true
	},
		"tile_is_at_least_two_value": {
			params = ["tile"],
			output = ["tile"],
			condition = true,
			read_only = true,
			run = func(params: Dictionary):
				var tile: Tile = params.tile
				if tile.get_value() >= 2:
					return {tile=tile}
				return false
	},
		"shuffle_faces_in_word": {
			params = ["word"],
			output = [],
			run = func(params: Dictionary):
				var word: WordList = params.word
				var tiles: Array[Tile] = word.tiles_list
				var shuffled_tiles := tiles.duplicate()
				rng.spell.shuffle(shuffled_tiles)
				
				for i in range(len(shuffled_tiles)):
					var tile_a = tiles[i]
					var tile_b = shuffled_tiles[i]
					tile_a.swap_face(tile_b)
				
				shuffled_tiles = []
				return true
	},
		"get_random_suffix": {
			params = [],
			output = ["ngram"],
			read_only = true,
			run = func(_params: Dictionary):
				var suffixes = Letters.COMMON_SUFFIXES
				return {ngram = rng.spell.pick_random(suffixes)}
	},
		"pick_a_tile": {
			params = [],
			output = ["tile","should_cancel_usage"],
			read_only = true,
			run = func(_params: Dictionary):
				var tile: Tile = await get_selection()
				if tile == null:
					return {should_cancel_usage=true}
	}
	
	
}
	
	
	#print(sections)
	for section in sections:
		sections[section] = sections[section].merged(DEFAULT_SECTION,false)
	
	var pick_section_filtered = func(fn: Callable):
		return rng.spell.pick_random(sections.keys().filter(fn))
	
	var valid_for_starting_clause = func(section_name: String):
		var section = sections[section_name]
		return section.read_only and section.condition and len(section.params) == 0
	
	var starting_clause: String = pick_section_filtered.call(valid_for_starting_clause)
	var valid_for_subclause = func(section_name: String, input_parameters: Array):
		var section = sections[section_name]
		for param in section.params:
			if param not in input_parameters:
				return false
		return !section.read_only
	
	var get_section_missing_parameter = func(available_parameters: Array, section: Dictionary):
		for parameter in section.params:
			if parameter not in available_parameters:
				return parameter
		return ""
	
	var get_self_contained_chain = func(recurse: Callable, can_be_conditional := true):
		var section_name = pick_section_filtered.call(
			func(s): return sections[s].read_only and len(sections[s].params) == 0 and (
				!sections[s].condition or can_be_conditional
			)
		)
		var section = sections[section_name]
		if section.condition:
			return {section_name:[recurse.call(recurse,false),recurse.call(recurse,false)]}
		
		var available_parameters = section.output
		
		var make_up_parameter = func(parameter: String): 
			return pick_section_filtered.call(
				func(s):
					return sections[s].output == [parameter] and len(sections[s].params) == 0
		)
		
		var following_section_name = pick_section_filtered.call(
			func(s):
				var missing_count = 0
				for parameter in sections[s].params:
					if parameter not in available_parameters and missing_count == 1:
						return false
					else:
						missing_count += 1
				return !sections[s].read_only
		)
		var following_section = sections[following_section_name]
		var missing = get_section_missing_parameter.call(available_parameters,following_section)
		if missing:
			following_section = {make_up_parameter.call(missing): following_section}
		return {section_name: following_section_name}
		
		
	
	var structure = {
		starting_clause: [
				get_self_contained_chain.call(get_self_contained_chain),
				get_self_contained_chain.call(get_self_contained_chain)
		]
	}
	
	print(structure)
