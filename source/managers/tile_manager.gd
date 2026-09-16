extends Node
class_name ProverbPalaceTileManager


const EPSILON = "ԑ"
const TILE_WRAPAROUND_ATLAS = preload("res://mods/proverbpalace/arte/tiles/tile_wraparound_atlas.png")

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
				print("replacement")
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

func _on_tile_updated(tile: Tile):
	#if !do_state_update_callback:
		#return
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

func _ready() -> void:
	if !connected_word_builder:
		Game.word_builder.tiles_updated.connect(
			_on_word_builder_tiles_updated
		)
		connected_word_builder = true

func _on_node_added(node: Node):
	var tile := node as Tile
	if node is WordBuilder:
		node.tiles_updated.connect(
			_on_word_builder_tiles_updated
		)
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
