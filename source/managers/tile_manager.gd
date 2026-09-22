extends Node
class_name ProverbPalaceTileManager


const EPSILON = "ԑ"
const TILE_WRAPAROUND_ATLAS = preload("res://mods/proverbpalace/arte/tiles/tile_wraparound_atlas.png")
const MUTAGEN_BUBBLES = preload("res://mods/proverbpalace/source/bubble/mutagen_bubbles.tscn")

static var stored_counterattack := 0



func tile_counts_as_epsilon(tile: Tile) -> bool:
	if tile.has_faceless_status():
		return false
	for face in tile.faces:
		if face == "" or face == EPSILON or EPSILON in face:
			return true
	return false

var do_state_update_callback := true

func _on_word_builder_tiles_updated():
	do_state_update_callback = false
	await get_tree().process_frame
	var can_submit = Game.word_builder.can_submit_tiles()
	for tile in Game.word_builder.tiles:
		fix_epsilon_faces(tile,!can_submit)
	Game.word_builder.resolve_words()
	Game.main.game_state_updated.emit()
	do_state_update_callback = true
	

func _on_tile_generate_tooltip(tooltip: Variant, tile: Tile):
	var using_spell = tile.player.get_using_spell()
	if using_spell != null:
		if using_spell.has_special_tile_tooltip():
			return
	
	if tile.has_faceless_status():
		return
	if tile_counts_as_epsilon(tile):
		tooltip.add_subtooltip(
			StringManager.get_string("status/epsilon/name"), 
			StringManager.get_string("status/epsilon/description")
		)

func fix_epsilon_faces(tile: Tile, should_have_epsilon: bool):
	var should_update := false
	if !tile_counts_as_epsilon(tile):
		return
	for i in range(len(tile.faces)):
		var face = tile.faces[i]
		if (face == EPSILON) and !should_have_epsilon:
			tile.set_face_at(i,"")
			should_update = true
			#print("toggle off")
		elif (face == "") and should_have_epsilon:
			tile.set_face_at(i,EPSILON)
			should_update = true
			#print("toggle on")
			#print(tile.faces)
		elif len(face) > 1:
			var only_epsilon := true
			for chr in face:
				if chr != EPSILON:
					only_epsilon = false
					break
			
			if only_epsilon:
				tile.set_face_at(i, EPSILON)
				should_update = true
			elif EPSILON in face:
				tile.set_face_at(i, face.replace(EPSILON,""))
				
			
	
	if should_update:
		tile.update_face()
	
	
func _on_tile_state_updated(tile: Tile, fix_others := true):
	return
	fix_epsilon_faces(tile,!tile.in_word())
	if tile.in_word() and fix_others:
		for t in tile.word_builder.tiles:
			if t != tile:
				_on_tile_state_updated(t,false)
	if tile.in_word() and tile_counts_as_epsilon(tile):
		tile.word_builder.resolve_words()
		if !tile.word_builder.can_submit_tiles():
			fix_epsilon_faces(tile,true)

func set_mutagen_enabled_for_sprite(sprite: TileSprite, enabled: bool):
	sprite.set_instance_shader_parameter("mutagen_enabled",enabled)
	
	for inheritor in sprite.material_inheritors:
		inheritor.set_instance_shader_parameter("mutagen_enabled",enabled)
	

func fix_mutagen_visuals(tile: Tile, is_in_word := true):
	if !tile.has_status("mutagen"):
		set_mutagen_enabled_for_sprite(tile.tile_sprite,false)
		return
	set_mutagen_enabled_for_sprite(tile.tile_sprite,true)
	tile.tile_face.set_deboss_color(
		"#999999"
	)
	tile.tile_face.set_color("#003300")
	tile.tile_face.value_color = "#003300"
	tile.tile_face.queue_redraw()
	

const MUTAGEN_EXCLUSIVE_STATUSES_GREATER = [
	Globals.TileEffect.POSITIVE_FACE,
	Globals.TileStatus.HOLE,
	Globals.TileStatus.MYSTERY
]
const MUTAGEN_EXCLUSIVE_STATUSES_LESSER = [
	Globals.TileStatus.CAPITAL,
	Globals.TileStatus.PERIOD
]



func fix_mutagen_tile(tile: Tile, is_in_word := true):
	if !tile.has_status("mutagen"):
		return
	
	
	if tile.has_any_effect(MUTAGEN_EXCLUSIVE_STATUSES_GREATER):
		tile.remove_status("mutagen")
		return
	
	for status in MUTAGEN_EXCLUSIVE_STATUSES_LESSER:
		if tile.has_status(status):
			tile.remove_status(status)
		
	tile.tile_sprite.set_frame(26)
	

func _on_tile_updated(tile: Tile):
	#if !do_state_update_callback:
		#retur
	fix_mutagen_tile(tile)
	fix_epsilon_faces(tile,!tile.in_word() or !tile.word_builder.can_submit_tiles())

const CUSTOM_SHADER = preload("res://mods/proverbpalace/overrides/source/shaders/tile_sprite.gdshader")

func set_epsilon_shader(tile: Tile, toggle: bool):
	tile.tile_sprite.set_instance_shader_parameter("epsilon_enabled",toggle)
	for inheritor in tile.tile_sprite.material_inheritors:
		if (inheritor == tile.tile_sprite.base_sprite):
			inheritor.set_instance_shader_parameter("epsilon_enabled",toggle)
		else:
			inheritor.set_instance_shader_parameter("epsilon_enabled",false)
			

func _on_tile_face_draw(tile: Tile):
	fix_mutagen_visuals(tile)
	if !tile_counts_as_epsilon(tile):
		return
	if "" == tile.faces[tile.tile_face.face_index]:
		tile.modulate.a = 0.35
		#tile.disable_shadow()
	else:
		tile.modulate.a = 1
		#tile.enable_shadow()
	set_epsilon_shader(tile,"" == tile.faces[tile.tile_face.face_index])

func _on_tile_added(tile: Tile):
	if tile.is_preview:
		fix_epsilon_faces(tile,true)
	tile.tile_sprite.material.shader = CUSTOM_SHADER
	(tile.tile_sprite.material as ShaderMaterial).set_shader_parameter("tile_wraparound",TILE_WRAPAROUND_ATLAS)

var connected_word_builder := false
const CUSTOM_INTENT = preload("res://mods/proverbpalace/source/custom_intent.tscn")

func update_counter_intent(intent_container,intent, context = null, tiles = null, create_if_not_found = false):
	if context == null:
		context = {}

	if tiles == null:
		tiles = []
	elif not tiles is Array:
		tiles = [tiles]

	#print("a")
	var intent_instance = intent_container.get_intent_instance(intent, context)
	if intent_instance != null:
		intent_instance.set_context(context, tiles)
		intent_container.updated_intents.append(intent_instance)
	elif create_if_not_found:
		var new_intent = CUSTOM_INTENT.instantiate()
		intent_container.intent_offset.add_child(new_intent)
		new_intent.set_intent(intent, context.duplicate(), tiles)
		intent_container.intent_instances.append(new_intent)
		intent_container.new_intents.append(new_intent)
		intent_container.updated_intents.append(new_intent)

func get_counter_tiles(tiles:Array[Tile]=Game.word_builder.tiles) -> Array[Tile]:
	return tiles.filter(
		func(tile: Tile): return tile.has_status("counter") and tile.get_value() > 0
	)

func get_counter_amount(tiles:Array[Tile]=Game.word_builder.tiles) -> int:
	var word_builder: WordBuilder = Game.word_builder
	var amt := 0
	for tile in get_counter_tiles(tiles):
		amt += tile.get_value()
	return ceili(amt*last_crit_multiplier)

var last_crit_multiplier := 1.

func _on_word_builder_finished_updating_stats(words):
	var word_builder: WordBuilder = Game.word_builder
	
	last_crit_multiplier = word_builder.damage_multiplier + word_builder.defense_multiplier - 1

	
	var counter_amt := get_counter_amount()
	
	if counter_amt > 0:
		update_counter_intent(
			word_builder.intent_container,
			ProverbPalaceCustomIntent.COUNTER_INTENT,{damage=counter_amt},get_counter_tiles(),true
		)

func init_word_builder(word_builder: WordBuilder):
	word_builder.tiles_updated.connect(
		_on_word_builder_tiles_updated
	)
	var inst = MUTAGEN_BUBBLES.instantiate()
	word_builder.add_child(inst)
	var word_holder = word_builder.get_node("WordHolder")
	word_holder.updated_tiles.connect(inst._on_word_holder_updated_tiles)
	word_builder.finished_updating_stats.connect(_on_word_builder_finished_updating_stats)
	word_builder.submitted_word.connect(_on_word_builder_submitted_word)


func _on_word_builder_submitted_word(words: WordList, damage: int, turn_ending: bool):
	
	var tiles: Array[Tile] = []
	for sublist in words.sub_lists:
		tiles.append_array(sublist.tiles_list)
	var counter_amount := get_counter_amount(tiles)
	stored_counterattack += counter_amount
	print("Adding %d to counterattack"%counter_amount)
	
	var player: Player = Game.player
	
	player.bruise_changed.emit()
	
	
	

func _ready() -> void:
	if !connected_word_builder:
		init_word_builder(Game.word_builder)
		
		connected_word_builder = true
const COUNTER_OVERLAY = preload("res://mods/proverbpalace/source/effects/counter_overlay.tscn")

func _on_node_added(node: Node):
	var tile := node as Tile
	if node is WordBuilder:
		init_word_builder(node)
		connected_word_builder = true
	if tile:
		await tile.ready
		tile.tooltip_collision.generate_tooltip.connect(
			_on_tile_generate_tooltip.bind(tile)
		)
		tile.state_updated.connect(_on_tile_state_updated.bind(tile))
		tile.updated.connect(_on_tile_updated.bind(tile))
		tile.tile_face.draw.connect(_on_tile_face_draw.bind(tile))
		_on_tile_added(tile)
