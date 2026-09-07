extends Spell
class_name Dynamo


const LIGHTNING_ARC_EFFECT = preload("res://mods/proverbpalace/source/spells/lightning_arc_effect.tscn")
const LIGHTNING_TILE_EFFECT = preload("res://mods/proverbpalace/source/effects/lightning_tile_effect.tscn")

const DYNAMO_SOUND = preload("res://mods/proverbpalace/sounds/dynamo.wav")

func set_status_tooltips():
	status_tooltips = [
		{
			status="arc_lightning"
		}
	]

# small adjustment to avoid duplicate weights
var LETTERS_ADJUSTED: Dictionary[String, float] = {
	"j": 1.0, 
	"q": 1.01, 
	"x": 1.02, 
	"z": 1.03, 
	"w": 1.04, 
	"k": 1.05, 
	"v": 1.06, 
	"f": 1.4, 
	"y": 1.6, 
	"b": 2.2, 
	"h": 2.3, 
	"m": 2.7, 
	"p": 3.01, 
	"g": 3.0, 
	"u": 3.3, 
	"d": 3.5, 
	"c": 4.0, 
	"l": 5.0, 
	"o": 6.01, 
	"t": 6.0, 
	"n": 7.01, 
	"r": 7.0, 
	"a": 7.5, 
	"i": 8.0, 
	"s": 8.5, 
	"e": 11.0, 
}

var is_selecting_first_tile := true

func apply_to_tile(tile: Tile):
	if !tile.has_face():
		return
	
	if tile.has_effect(TileEffect.SHIMMERING) or tile.has_status(TileStatus.MYSTERY) or tile.contains_wildcard():
		tile.randomize_similar_face(rng.spell)
		return
	
	var N_GET_MIN_WEIGHT_ACROSS := 4
	
	var ngrams: Dictionary[String,float] = get_pool_for_n_lettered_grams(len(tile.face))
	var max_weight_within_ngrams: float = ngrams.values().max()
	
	var weight_within_ngrams = ngrams.get(tile.face)
	if (weight_within_ngrams == null) or is_equal_approx(weight_within_ngrams,max_weight_within_ngrams):
		tile.add_status(TileStatus.COAL)
		return
	
	var get_ngram_based_on_min_option = func(option_count: int):
		var possible_choices = []
		for i in option_count:
			possible_choices.append(Letters.pick_from_pool(
				ngrams, rng.spell, {min_weight = weight_within_ngrams, exclude_letters = [tile.face] + possible_choices}
			))
		possible_choices.sort_custom(
			func(a,b):
				return ngrams[a] < ngrams[b]
		)
		return possible_choices[0]
	
	var choice = get_ngram_based_on_min_option.call(N_GET_MIN_WEIGHT_ACROSS)
	if ngrams[choice] < ngrams[tile.face]:
		choice = get_ngram_based_on_min_option.call(1)
	
	tile.set_face(choice)


func get_tooltip_context():
	return {
		"selecting_first_tile" = is_selecting_first_tile
	}

func get_pool_for_n_lettered_grams(n: int):
	match n:
		1:
			return LETTERS_ADJUSTED
		2:
			return Letters.BIGRAMS
		3:
			return Letters.TRIGRAMS
		4:
			return Letters.TETRAGRAMS
	return {}


func _use():
	is_selecting_first_tile = true
	var first_tile = await get_selection()
	is_selecting_first_tile = false
	update_banner_label()
	if first_tile == null:
		_end_use()
		return

	first_tile.animation.play("pressed")

	var second_tile = await get_selection([first_tile])
	if second_tile == null:
		_end_use()
		return

	#AudioManager.play_sound(Sounds.BOOKWORM.FIREBALL,.4)
	AudioManager.play_sound(DYNAMO_SOUND,1.)
	
	var coord_a := first_tile.get_coord()
	var coord_b := second_tile.get_coord()
	
	var line := Geometry2D.bresenham_line(coord_a,coord_b)
	var line_ba := Geometry2D.bresenham_line(coord_b,coord_a)
	line_ba.reverse()
	var i = 1
	for coord in line_ba:
		if (coord not in line):
			line.insert(i,coord)
		i += 1
	
	var tiles: Array[Tile] = []
	
	
	for coord in line:
		tiles.append(tile_board.get_tile_at(coord))
	
	var arc := LIGHTNING_ARC_EFFECT.instantiate() as LightningArc
	arc.tile_list_to_init = tiles
	main.add_child(arc)
	
	for tile in tiles:
		apply_to_tile(tile)
		tile.animation.play("shake",-1,1.56)
		tile.tile_sprite.add_child(LIGHTNING_TILE_EFFECT.instantiate())
		await Game.timeout(.03)
		
	

	_post_use()
	description_updated.emit()


func is_tile_selectable(tile: Tile) -> bool:
	return true
