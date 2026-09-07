extends TileModifierSpell

enum CatchyMode {
	SEQUENTIAL, #ex. 3456
	SEQUENTIAL_REVERSED, #ex. 7654
	DUPED_SINGLE, #ex. 8888
	DUPED_PAIRS, #ex. 5566
	DUPED_WEAVED, #ex. 3939
	TRIPLE_SINGLE, #ex. 5557
	SINGLE_TRIPLE, #ex. 3222
	ODDS, # always 3579
	EVENS, # always 2468
	MODE_MAX
}

const DISSENTER_HOTLINE_EFFECT_INSTANCE = preload("res://mods/proverbpalace/source/spells/dissenter_hotline/dissenter_hotline_effect_instance.tscn")


var number_sequence: Array[String] : get=generate_number_sequence
const DISSENTER_HOTLINE_DELAY_CURVE: Curve = preload("res://mods/proverbpalace/source/resources/dissenter_hotline_delay_curve.tres")

static var STA_DEBUG_SEED := 0
var DEBUG_SEED := 0

const ONE_254_EASTER_EGG_CHANCE := 0.001 # 0.1%

const DO_DEBUG_SET_SEED := false

func _spell_init():
	if OS.has_feature("debug") and DO_DEBUG_SET_SEED:
		DEBUG_SEED = STA_DEBUG_SEED
		STA_DEBUG_SEED += 1

func _first_spawn(is_transform: = false) -> void:
	super(is_transform)

func get_sequence_seed() -> int:
	if OS.has_feature("debug") and DO_DEBUG_SET_SEED:
		return DEBUG_SEED
	return Game.main.rng.spell.seed

func generate_number_sequence() -> Array[String]:
	
	var num_rng = RNG.new()
	num_rng.state = 0
	num_rng.seed = get_sequence_seed()
	
	
	if (num_rng.randf() < ONE_254_EASTER_EGG_CHANCE):
		return ["one","2","5","4"]
	
	var catchy_mode := num_rng.randi()%CatchyMode.MODE_MAX as CatchyMode
	if catchy_mode == CatchyMode.ODDS:
		return ["3","5","7","9"]
	if catchy_mode == CatchyMode.EVENS:
		return ["2","4","6","8"]
	
	
	if catchy_mode in [CatchyMode.SEQUENTIAL, CatchyMode.SEQUENTIAL_REVERSED]:
		var starting_num_index: int = num_rng.randi()%(len(Letters.NUMBERS)-3)
		var arr: Array[String] = Letters.NUMBERS.slice(starting_num_index,starting_num_index+4)
		if catchy_mode == CatchyMode.SEQUENTIAL_REVERSED:
			arr.reverse()
		return arr
	
	var num1: String = Letters.NUMBERS[num_rng.randi()%(len(Letters.NUMBERS))]
	if catchy_mode in [CatchyMode.DUPED_PAIRS, CatchyMode.DUPED_WEAVED, CatchyMode.TRIPLE_SINGLE, CatchyMode.SINGLE_TRIPLE]:
		var remaining_nums := Letters.NUMBERS.duplicate()
		remaining_nums.erase(num1)
		var num2: String = remaining_nums[num_rng.randi()%len(remaining_nums)]
		if catchy_mode == CatchyMode.DUPED_PAIRS:
			return [num1,num1,num2,num2]
		if catchy_mode == CatchyMode.DUPED_WEAVED:
			return [num1,num2,num1,num2]
		if catchy_mode == CatchyMode.SINGLE_TRIPLE:
			return [num1,num2,num2,num2]
		if catchy_mode == CatchyMode.TRIPLE_SINGLE:
			return [num1,num1,num1,num2]
		
	return [num1,num1,num1,num1]
	
	

func get_tooltip_context():
	return {
		number_list = number_sequence
	}
	
func set_status_tooltips():
	var description = ""
	var already_processed = []
	var seq = generate_number_sequence()
	for number in seq:
		if !(number in already_processed):
			if number != "one":
				var number_description = StringManager.get_string("status/number/specific_description", {number = number, letters = Letters.NUMPAD_CHARACTERS[number]})
				description += number_description + "\n"
				already_processed.append(number)
	status_tooltips = [
		TileStatus.SPICY, 
		{status="special_number_sequence",string_lines=description}
	]

func apply_from_number_sequence(tile: Tile, i: int, fx_rng: RNG) -> GenericTileEffect:
	assert(i < len(number_sequence))
	var next_tile := tile.get_board_neighbor(Vector2.RIGHT)
	
	
	var picked_sound = fx_rng.pick_random(Sounds.PROLE_SERVICE.TONE.SOUNDS)
	
	
	
	var inst := DISSENTER_HOTLINE_EFFECT_INSTANCE.instantiate() as GenericTileEffect
	inst.do_play_sound = func():
		
		AudioManager.play_sound(
			picked_sound,
			1.,
			.15
			)
		#AudioManager.play_sound(
			#Sounds.GENERIC.APPLY_STATUS
		#)
		AudioManager.play_sound(Sounds.BOOKWORM.FIREBALL)
		
		tile.set_face(number_sequence[i])
		pass
	inst.frame_coords = tile.tile_sprite.base_sprite.frame_coords
	tile.tile_sprite.add_child(inst)
	inst.atlas = tile.tile_sprite.base_sprite.texture
	inst.dont_change = false
	inst.bounce.connect(
		func():
			tile.animation.play("pressed")
	)
	
	tile.add_status(TileStatus.SPICY)
	
	if next_tile and (i+1 < len(number_sequence)):
		var delay_time := DISSENTER_HOTLINE_DELAY_CURVE.sample(fx_rng.randf())
		delay_time = snappedf(delay_time,.033333)
		await Game.timeout(delay_time)
		return await apply_from_number_sequence(next_tile, i+1,fx_rng)
	return inst

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	if not is_preview:
		var fx_rng := RNG.new()
		fx_rng.state = 0
		fx_rng.seed = get_sequence_seed()
		#tile.add_poofcloud(tile.get_color())
		var effect := await apply_from_number_sequence(tile,0,fx_rng)
		await effect.effect_finished
	else:
		tile.add_status(TileStatus.SPICY)
		tile.set_face(number_sequence[0])
	


func is_tile_selectable(tile: Tile) -> bool:
	return (
		!(tile.has_number() and tile.has_status(TileStatus.SPICY))
	)
