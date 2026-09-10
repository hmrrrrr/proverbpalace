extends TileModifierSpell


var current_trigram := ""
var current_trigram_count := 1

const STREAMER = preload("res://mods/proverbpalace/source/effects/streamer.tscn")


const RARITY_NAMES = [
	"abundant",
	"common",
	"uncommon",
	"rare",
	"very rare",
	"horrific",
	"cij"
]

const RARITY_CUTOFFS = [
	200,
	55,
	32,
	17,
	6,
	1,
	0
]

func get_save_data():
	return {current_trigram=current_trigram, current_trigram_count=current_trigram_count}
	
func load_save_data(save):
	current_trigram = save.current_trigram
	current_trigram_count = save.current_trigram_count

func _first_spawn(is_transform: = false) -> void:
	super(is_transform)
	
	current_trigram = rng.spell.pick_random(["ers","ter","lin"])
	current_trigram_count = get_trigram_count(current_trigram)
	
func get_next_trigram() -> String:
	
	var trigram_pool = Trigrams.GOOD_TRIGRAMS
	var max_weight = current_trigram_count-1
	
	if current_trigram_count <= 2:
		trigram_pool = Trigrams.SHIT_TRIGRAMS
		if rng.spell.randi_range(0,12) != 0: #1/12 to be forced toward cij
			max_weight += 1
	if max_weight == 0:
		return "cij"
	return Letters.pick_from_pool(
		trigram_pool, rng.spell, {
			max_weight=max_weight,
			min_weight=floorf(current_trigram_count*.73)
			})

func get_tooltip_context():
	var rarity := ""
	for i in range(len(RARITY_CUTOFFS)):
		if current_trigram_count >= RARITY_CUTOFFS[i]:
			rarity = RARITY_NAMES[i]
			break
	
	
	return {rarity = rarity}
	
func set_status_tooltips():
	status_tooltips = [{status=TileStatus.BOMB,bomb_turns=1}]

func create_streamer_trail(proj: ArcingProjectile, color = "PURPLE", offset := Vector2.ZERO):
	var streamer := STREAMER.instantiate() as Streamer
	streamer.streamer_color = color
	streamer.bound_projectile = proj
	
	
	main.projectile_container.add_child(streamer)
	main.projectile_container.move_child(streamer,0)
	streamer.offset = offset

func get_trigram_count(trigram: String):
	if trigram in Trigrams.GOOD_TRIGRAMS:
		return Trigrams.GOOD_TRIGRAMS[trigram]
	return Trigrams.SHIT_TRIGRAMS[trigram]

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	
	if is_preview:
		tile.set_type(TileType.DAMAGE)
		tile.add_status(TileStatus.BOMB,1)
		tile.set_face("???")
	else:
		var new_tile = tile_board.create_tile()
		main.add_child(new_tile)
		new_tile.add_status(TileStatus.BOMB,1)
		new_tile.set_face(current_trigram)
		
		var coord = tile.get_coord()
		var starting_position = player_spell_slot.global_position + Vector2(92,48)/2.
		var proj := new_tile.launch(
			starting_position,
			tile_board.get_coord_position(coord),
			starting_position.y - tile_board.get_coord_position(coord).y + 23,coord,
			1450, false, true
		)
		#create_streamer_trail(proj,"YELLOW")
		#create_streamer_trail(proj,"PURPLE",Vector2(-4,0))
		#create_streamer_trail(proj,"PURPLE",Vector2(4,0))
		
		if current_trigram_count > 0:
			current_trigram = get_next_trigram()
			current_trigram_count = get_trigram_count(current_trigram)
			
			description_updated.emit()
		await proj.impacted
		
		#proj.look_at_direction = false
		


func is_tile_selectable(tile: Tile) -> bool:
	return (
		!tile.has_harmful_status() 
	)
