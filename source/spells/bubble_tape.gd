extends Spell

func is_coop_enabled() -> bool:
	return ModLoader.mods.any(func (mod:Mod)->bool:return mod.id=="co-op")
	
func is_pirate_mod_enabled() -> bool:
	return ModLoader.mods.any(func (mod:Mod)->bool:return mod.id=="pronoun_pirates")

const FUNNY_TETRAGRAMS = [
		"well", "bull", "rope", "terf", "harm", "weed", "titi", "sona", "misc",
		"homo", "anal", "rack", "tism", "fish", "zing"
	]

const SPELLS_SHOWN_OR_MENTIONED_IN_CUTSCENES = [
	SPELLS.LETTER_OPENER, SPELLS.PARTY_RATION, SPELLS.GIRL_PILLS, SPELLS.SALT,
	SPELLS.VICTORY_WHISKEY, SPELLS.CIGARETTE, SPELLS.CIGARETTE_BUTT, SPELLS.CLOVER,
	
	SPELLS.PLIERS, SPELLS.RAZOR_BLADE,
]

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

enum {
	PROVIDER,
	CONDITION,
	HANDLING_CONDITION,
	ARBITRARY_CONDITION,
	ENDPOINT,
}



var structure: Dictionary = {}

var sections_for_description: Dictionary[String, Array] = {}

var sections: Array[Dictionary] = []

var country_code: String = Steam.getIPCountry().to_lower()

func _first_spawn(is_transform: = false) -> void:
	randomize_sections(rng.spell)
	super(is_transform)

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
	
	

func get_random_section_by_object(bubble_rng: RNG, required_input_parameter: String, include_types: Array):
	var weights = {}
	for section in sections:
		if (required_input_parameter == "" or required_input_parameter in
		section.object or section.object == ""
		or section.type == ARBITRARY_CONDITION) and section.type in include_types:
			weights[section] = section.weight
	return bubble_rng.weighted_random(weights)
	

func pretty_print_section(section: Dictionary, indent_level := 0,prefix:=""):
	var children = []
	match section.type:
		PROVIDER:
			children.append("next")
		CONDITION, ARBITRARY_CONDITION:
			children.append("next_if_yes")
			children.append("next_if_no")
		HANDLING_CONDITION:
			children.append("next_if_no")
	
	print((prefix+(section.id)).indent("\t".repeat(indent_level)))
	for child in children:
		match child:
			"next":
				prefix = "then: "
			"next_if_yes":
				prefix = "if yes: "
			"next_if_no":
				prefix = "if not: "
		pretty_print_section(section[child],indent_level+1,prefix)

func get_first_valid_parent_object_type(section: Dictionary, restrict_types := [ARBITRARY_CONDITION, CONDITION, ENDPOINT, HANDLING_CONDITION, PROVIDER], allow_self := true) -> String:
	if section.object != "" and section.type in restrict_types and allow_self:
		return section.object
	
	if !section.has("parent"):
		return ""
	
	return get_first_valid_parent_object_type(get_section_by_id(section.parent), restrict_types, true)

func fill_out_section(bubble_rng: RNG, section: Dictionary, depth := 0, desired_depth := 2):
	var needed_types = []
	var needed_children = []
	match section.type:
		PROVIDER:
			needed_children.append("next")
			needed_types = [CONDITION,HANDLING_CONDITION,ARBITRARY_CONDITION]
		CONDITION, ARBITRARY_CONDITION:
			needed_children.append("next_if_yes")
			needed_children.append("next_if_no")
			needed_types = [CONDITION,HANDLING_CONDITION,ARBITRARY_CONDITION, ENDPOINT]
		HANDLING_CONDITION:
			needed_children.append("next_if_no")
			needed_types = [CONDITION,HANDLING_CONDITION,ARBITRARY_CONDITION, ENDPOINT]
	
	if len(needed_types) == 0:
		return
	
	if depth >= desired_depth and ENDPOINT in needed_types:
		needed_types = [ENDPOINT]
	else:
		needed_types.erase(ENDPOINT)
	
	for child in needed_children:
		var req = ""
		var fulfillment_types = [PROVIDER, ARBITRARY_CONDITION]
		var word_begets_valid_submission = not ("no" in child and "word" == section.object)
		
		if (get_first_valid_parent_object_type(section,fulfillment_types,false) != section.object):
			needed_types.erase(ARBITRARY_CONDITION)
		if word_begets_valid_submission:
			req = get_first_valid_parent_object_type(section)
		
		
		section[child] = get_random_section_by_object(
			bubble_rng,
			req
			,needed_types)
		section[child].weight *= 0.001
		section[child].parent = section.id
		fill_out_section(bubble_rng,section[child],depth+1,desired_depth)

func get_section_by_id(section_id: String):
	for section in sections:
		if section.id == section_id:
			return section

func randomize_sections(bubble_rng: RNG):
	var random_category_name = get_random_word_category(bubble_rng)
	var random_category = Globals.WORD_CATEGORY_FLAGS[random_category_name]

	var random_neg_status = bubble_rng.pick_random(
		[
			TileStatus.BRUISE,TileStatus.ASH,TileStatus.CAPITAL,TileStatus.GUNK,TileStatus.MONEY,TileStatus.SPICY
		]
	)
	var random_defensive_status = bubble_rng.pick_random(
		[
			TileStatus.FROZEN, TileStatus.CANDY
		]
	)
	var random_offensive_status = bubble_rng.pick_random(
		[
			TileStatus.CRIT, TileStatus.ENHANCED, TileStatus.FROZEN
		]
	)
	
	var make_status_application_section = func(status:String):
		return {id="try_apply_status",
				object="tile",
				context = {status=status},
				type = HANDLING_CONDITION,
				weight = .75,
				run = func(param):
					var tile: Tile = param
					if tile.has_status(status):
						return false
					tile.add_status(status)
					return {tile=tile}
		}
	
	
	var random_letter = bubble_rng.pick_random(Letters.ALPHABET)
	var random_number = bubble_rng.pick_random(Letters.NUMBERS)
	var random_tetragram = bubble_rng.pick_random(FUNNY_TETRAGRAMS)
	
	sections = [
		make_status_application_section.call(random_neg_status),
		make_status_application_section.call(random_offensive_status),
		make_status_application_section.call(random_defensive_status),
		{
			id = "enemy_at_half_hp",
			object="",
			type = ARBITRARY_CONDITION,
			run = func(_param: Variant):
				var enemy := (main.enemy as Enemy)
				return enemy.health <= ceili(enemy.max_health/2.)
	},
		{
			id = "is_tile_specific_letter",
			object="tile",
			type = CONDITION,
			weight = .4,
			context = {letter=random_letter},
			run = func(param: Variant):
				var tile := param as Tile
				if tile.only_face_is(random_letter):
					return {tile=tile}
				return false
	},
		{
			id = "swap_tile_type",
			object="tile",
			type = ENDPOINT,
			run = func(param: Variant):
				var tile: Tile = param
				tile.set_type(TileType.DAMAGE if tile.is_type(TileType.DEFENSE) else TileType.DEFENSE)
				return tile
	},
		{
			id = "set_to_specific_number",
			object="tile",
			context={number=random_number},
			type = HANDLING_CONDITION,
			run = func(param: Variant):
				var tile: Tile = param
				if tile.only_face_is(random_number):
					return false
				tile.set_face(random_number)
				return {tile=tile}
	},
		#{   id ="get_spelled_word",
			#object="word",
			#type = ARBITRARY_CONDITION,
			#run = func(param: Variant):
				#if !(word_builder.can_submit_tiles() and word_builder.can_submit_words(word_builder.words_list)):
					#return false
				#var first_word = word_builder.words_list.get_first_word()
				#if first_word:
					#return first_word
				#return false
	#},
		#{ 	id = "word_is_in_category",
			#object="word",
			#type = CONDITION,
			#context = {category = random_category_name},
			#run = func(param):
				#var word: WordList = param
				#if WordUtility.word_list_has_flag(word, random_category) and word.sub_lists.size() == 1:
					#return word
				#return false
	#},
		{id="tile_is_faceless",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				if !tile.has_face():
					return {tile=tile}
				return false
	},
		{id="tile_has_harmful_status",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				if tile.has_harmful_status():
					return {tile=tile}
				return false
	},
		{id="tile_is_plastic",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				if tile.type == TileType.DEFENSE:
					return {tile=tile}
				return false
	},
		{id="tile_is_wood",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				if tile.type == TileType.DAMAGE:
					return {tile=tile}
				return false
	},
		{id="is_tile_in_bottom_row",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				var bottom_row = get_tiles({
					rows = [0], 
				})
				if tile in bottom_row:
					return {tile=tile}
				return false
	},
		{id="board_contains_only_default",
			object="",
			type = ARBITRARY_CONDITION,
			weight = .5,
			run = func(_param):
				var tiles = get_tiles({
				})
				for tile: Tile in tiles:
					if !tile.has_status(TileStatus.DEFAULT):
						return false
				return true
	},
		#"pick_random_tile": {
			#params = [],
			#output = ["tile"],
			#type = PROVIDER,
			#run = func(_params: Dictionary):
				#var tiles: Array[Tile] = tile_board.get_tiles({amount = 1})
				#if len(tiles) == 0:
					#return false
				#return {
					#tile = tiles[0]
				#}
	#},
		{id="has_fib_hp",
			object="",
			weight = .5,
			type = ARBITRARY_CONDITION,
			run = func(_param):
				return player.health in FIBONACCI_NUMBERS
	},
		{id="has_odd_number_of_tiles",
			object="",
			weight = .5,
			type = ARBITRARY_CONDITION,
			run = func(_param):
				return len(tile_board.get_tiles())%2==1
	},
		{id="has_spell_shown_or_mentioned_in_cutscene",
			object="",
			weight = .5,
			type = ARBITRARY_CONDITION,
			run = func(_param):
				return player.get_spells().any(
					func(spell: Spell): return spell.id in SPELLS_SHOWN_OR_MENTIONED_IN_CUTSCENES
				)
	},
		{id="fighting_enemy_shadow",
			object="",
			weight = .5,
			type = ARBITRARY_CONDITION,
			run = func(_param):
				return Enemies.is_shadow(
					(main.enemy as Enemy).id
				)
	},
		{id="place_country_code_bigram",
			object="tile",
			type = ENDPOINT,
			run = func(param):
				var tile: Tile = param
				var face = country_code
				if len(face) != 2:
					face = "uh"
				 
				tile.set_face(face)
	},
		{id="convert_to_epsilon",
			object="tile",
			type = ENDPOINT,
			run = func(param):
				var tile: Tile = param
				tile.set_face(ProverbPalaceTileManager.EPSILON)
	},
		{id="convert_to_tetragram",
			object="tile",
			type = ENDPOINT,
			context = {tetragram = random_tetragram},
			run = func(param):
				var tile: Tile = param
				tile.set_face(random_tetragram)
	},
		{id="place_three_or_less_letter_word_on_tile",
			object="tile",
			type = HANDLING_CONDITION,
			run = func(param):
				var words: WordList = word_builder.get_words()
				var tile: Tile = param
				if word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1 and word_builder.tiles.size() <= 3:
					tile.set_face(word_builder.word.sub_lists[0].get_first_word())
				else:
					return false
				return {tile=tile}
	},
		{id="shift_forward_consonant",
			object="tile",
			type = HANDLING_CONDITION,
			run = func(param):
				var tile: Tile = param
				if tile.has_single_face(1) and tile.face in Letters.CONSONANTS:
					var shift_face = Letters.shift_face(
						tile.face, 
						[Letters.ALPHABET], 
						1
					)
					tile.set_face(shift_face)
					return {tile=tile}
				return false
	},
		{id="append_cow_bigram",
			object="tile",
			type = HANDLING_CONDITION,
			run = func(param):
				var tile: Tile = param
				if !tile.is_single_letter(false,false):
					return false
				if tile.face not in COW_BIGRAMS:
					return false
				tile.set_face(COW_BIGRAMS[tile.face])
				return {tile=tile}
	},
		{id="face_all_from_back_half_of_alphabet",
			object="tile",
			type = CONDITION,
			
			run = func(param):
				var tile: Tile = param
				var alpha_second_half = Letters.ALPHABET.slice(13)
				if !tile.has_single_face(99):
					return false
				var face := tile.face
				for let in face:
					if let not in alpha_second_half:
						return false
				return tile
	},
		{id="ngram_in_character_name",
			object="tile",
			type = CONDITION,
			
			run = func(param):
				var tile: Tile = param
				var character_full_name := StringManager.get_string(
					"character/%s/name"%player.id,
					{trans=player.is_trans()}
					)
				return tile.face in character_full_name
	},
		{id="make_capital_wildcard",
			object="tile",
			type = HANDLING_CONDITION,
			run = func(param):
				var tile: Tile = param
				if tile.only_face_is("*") and tile.has_status(TileStatus.CAPITAL):
					return false
				
				tile.set_face("*")
				tile.add_status(TileStatus.CAPITAL)
				return true
	},
		{id="tile_is_single_number",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				if len(tile.get_numbers()) == len(tile.face) and tile.has_single_face(1):
					return tile
				return false
	},
		{id="remove_tile",
			object="tile",
			type = ENDPOINT,
			run = func(param):
				var tile: Tile = param
				await letter_opener_tile_launch(tile)
				return true
	},
		{id="tile_is_at_least_two_value",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				if tile.get_value() >= 2:
					return tile
				return false
	},
		{id="get_tile_neighbor",
			object="tile",
			type = CONDITION,
			run = func(param):
				var tile: Tile = param
				var neighbors := tile.get_board_neighbors()
				if len(neighbors) > 0:
					rng.spell.shuffle(neighbors)
					return neighbors[0]
				return false
	},
		{id="shuffle_faces_in_word",
			object="word",
			type = ENDPOINT,
			run = func(param):
				var word: WordList = param
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
		#{id="pick_a_tile",
			#params = [],
			#output = ["tile"],
			#type = PROVIDER,
			#should_cancel_usage = true,
			#run = func(_params: Dictionary):
				#var tile: Tile = await get_selection()
				#if tile == null:
					#return false
				#return {tile=tile}
	#}
		{id="pick_a_tile",
			object="tile",
			type = PROVIDER,
			should_cancel_usage = true,
			run = func(_param):
				var tile: Tile = await get_selection()
				if tile == null:
					return false
				return {tile=tile}
	}
	
	
]

	var starting_sections = [
		"pick_a_tile"
	]
	
	
	for section in sections:
		if !section.has("weight"):
			section.weight = 1. if section.id not in starting_sections else 0.
		if !section.has("context"):
			section.context = {}
	
	structure = get_section_by_id(bubble_rng.pick_random(starting_sections))
	fill_out_section(bubble_rng,structure,0,2)
	#pretty_print_section(structure)
	sections_for_description = {}
	create_sections_for_description(structure)
	

const SECTION_NAMES = Letters.ALPHABET

func get_next_section_name() -> String:
	for let in SECTION_NAMES:
		if let not in sections_for_description:
			return let
	return "z"


func create_sections_for_description(section: Dictionary, current_description_section := "base") -> void:

	var otherwise = get_string_group().get_string("verbiage/otherwise")
	
	if !sections_for_description.has(current_description_section):
		sections_for_description[current_description_section] = []
		
	sections_for_description[current_description_section].append(get_section_string(section))
	
	match section.type:
		PROVIDER:
			create_sections_for_description(section.next,current_description_section)
		HANDLING_CONDITION:
			sections_for_description[current_description_section].append(otherwise)
			create_sections_for_description(section.next_if_no,current_description_section)
		CONDITION, ARBITRARY_CONDITION:
			for child in ["next_if_yes","next_if_no"]:
				if child == "next_if_no":
					sections_for_description[current_description_section].append(otherwise)
				if section[child].type == ENDPOINT:
					create_sections_for_description(section[child],current_description_section)
					continue
				var see_next_section = get_string_group().get_string("verbiage/see_section",{section=get_next_section_name()})
				sections_for_description[current_description_section].append(see_next_section)
				create_sections_for_description(section[child],get_next_section_name())

func get_description_text_from_array(arr: Array) -> String:
	var base_description := ""
	var should_capitalize := true
	
	for i in range(len(arr)):
		var entry = arr[i]
		base_description += (capitalize_first_letter_in_string(entry) if should_capitalize else entry)
		
		if i < len(arr)-1:
			base_description += " "
			
		should_capitalize = should_capitalize_next_part_of_section(entry)
	
	return base_description
	
	


func get_section_name(section_letter: String):
	return get_string_group().get_string("verbiage/section",{section=section_letter})

func get_description() -> String:
	return get_description_text_from_array(sections_for_description.base)

func has_spell_select_tooltip() -> bool:
	return not has_curse(CURSE.CENSORED)
	
func generate_spell_select_tooltip(tooltip: GameTooltip) -> void:
	for section in sections_for_description:
		if section != "base":
			tooltip.add_subtooltip(get_section_name(section), get_description_text_from_array(sections_for_description[section]))
	print("OIFJAOFJOIA")
	post_generate_tooltip(tooltip)

func generate_player_spell_tooltip(tooltip: GameTooltip) -> void :
	

	for section in sections_for_description:
		if section == "base":
			tooltip.add_subtooltip(get_title(), get_description_text_from_array(sections_for_description[section]))
		else:
			tooltip.add_subtooltip(get_section_name(section), get_description_text_from_array(sections_for_description[section]))
			
	
	if is_cursed() and curse not in [CURSE.CENSORED, CURSE.NOSTALGIC, CURSE.SHINY]:
		if id == secret_id or secret_id not in Globals.GIFTS or not has_curse(CURSE.CURSED):
			add_curse_subtooltip(tooltip)

	add_status_subtooltips(tooltip)
	
	
	
	post_generate_tooltip(tooltip)


func should_capitalize_next_part_of_section(string: String):
	return string[-1] == "."

func capitalize_first_letter_in_string(string: String):
	if len(string) <= 1:
		return string.to_upper()
	return string.substr(0,1).to_upper() + string.substr(1)

func get_section_string(section: Dictionary):
	return get_string_group().get_string("verbiage/%s"%section.id,section.context)
