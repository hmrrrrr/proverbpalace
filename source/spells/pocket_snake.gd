extends Spell

const SNAKE_SEGMENT = preload("res://mods/proverbpalace/source/spells/snake_segment.tscn")

var current_pigment: Color


func create_segment(tile: Tile) -> SnakeSegment:
	var segment := SNAKE_SEGMENT.instantiate() as SnakeSegment
	tile.tile_sprite.add_child(segment)
	segment.self_modulate = current_pigment
	return segment



var colors_image: Image


func _ready() -> void:
	colors_image = SNAKECOLORS.get_image()

var on_first_tile := true

var tiles: Array[Tile] = []

const SNAKECOLORS = preload("res://mods/proverbpalace/source/resources/snakecolors.png")

static func get_random_snake_color_coordinate() -> Vector2i:
	var img := SNAKECOLORS.get_image() as Image
	var bounds = img.get_size()
	
	return Vector2i(
		randi()%bounds.x,
		randi()%bounds.y
	)

func get_tooltip_context():
	return {
		"selecting_first_tile" = on_first_tile
	}

func _use():
	var segments: Array[SnakeSegment] = []
	tiles = []
	var can_continue_snaking := true
	on_first_tile = true
	const violence_interval = 0.0833
	
	var color_coord_walk: Vector2i = get_random_snake_color_coordinate()
	var walk_direction = Vector2i(
		randi_range(-1,1),
		1 if randi()%2==0 else -1
	)
	
	var destroy_segments := func(violent = false):
		for tile in tiles:
			tile.state = Tile.State.IDLE
			tile.update_z_index()
			
			
			tile.hover_handler.set_disabled(false,true)
			
		var last_signal
		for i in range(len(segments)):
			var segment = segments[i]
			var tile = tiles[i]
			last_signal = segment.die_animation()
			last_signal.connect(
				func():
					segment.parent_scale = Vector2.ONE
					segment.queue_free()
					if violent:
						AudioManager.play_sound(Sounds.GENERIC.BLOOD_EXPLODE,1.15,.5)
						var bomb_status = tile.get_status(TileStatus.BOMB)
						if bomb_status:
							await bomb_status.explode(false,true)
						else:
							tile.add_poofcloud(segment.self_modulate,null,false)
						tile_board.remove_tile_from_board(tile)
						tile.clear()
			)
			if violent:
				await Game.timeout(violence_interval)
		if last_signal and last_signal.get_object():
			await last_signal
	
	var pitch := 1.
	while can_continue_snaking:
		var chosen_tile = await get_selection(tiles)
		if chosen_tile == null:
			
			destroy_segments.call()
			_end_use()
			return
			
		var relative_to_last_direction := Vector2i.ZERO
		var prev_tile : Tile
		var prev_segment : SnakeSegment
		if !on_first_tile:
			prev_tile = tiles[-1]
			prev_segment = segments[-1]
			relative_to_last_direction = chosen_tile.get_coord() - prev_tile.get_coord()
			relative_to_last_direction *= Vector2i(1,-1)
			prev_segment.update_state(Vector2i.ZERO, len(tiles) == 1)
		
		
		color_coord_walk += walk_direction
		color_coord_walk = color_coord_walk.clamp(Vector2i.ZERO,colors_image.get_size()-Vector2i.ONE)
		current_pigment = colors_image.get_pixelv(color_coord_walk)
		
		tiles.append(chosen_tile)
		chosen_tile.hover_handler.set_disabled(true,true)
		#chosen_tile.animation.play("reroll")
		
		# TODO 
		# MAKE THIS SHIT GOOD. GET RID OF Z INDEX FUCKERY AND
		# JUST USE THE TILE'S BASE Z INDEX, PUTTING THE CONNECTION OVERLAY
		# ON THE PRESIDING TILE
		
		chosen_tile.state = Tile.State.REMOVING
		var segment := create_segment(chosen_tile)
		segments.append(segment)
		AudioManager.play_sound(Sounds.BOOKWORM.MILKWORM_FIREBALL,pitch)
		pitch *= 1.05946309436
		if prev_tile:
			var other_segment := segment
			var presiding_segment := prev_segment
			var connection_direction := relative_to_last_direction
			if (chosen_tile.z_index > prev_tile.z_index):
				presiding_segment = segment
				other_segment = prev_segment
				connection_direction *= -1
			
			presiding_segment.add_connection_overlay(connection_direction,other_segment)
		
		if on_first_tile:
			on_first_tile = false
			update_banner_label()
		else:
			segment.update_state(relative_to_last_direction)
		
		var valid_neighbors := chosen_tile.get_board_neighbors().filter(
			func(t: Tile): return t not in tiles
		)
		if len(valid_neighbors) == 0:
			can_continue_snaking = false
		if chosen_tile.has_any_status(
			[TileStatus.BOMB,TileStatus.POISON,TileStatus.CURSED,TileStatus.ETERNAL]
		):
			can_continue_snaking = false
	segments[-1].make_face_dead()
	var playback := AudioManager.play_sound(Sounds.ANTI_SEX_WORKER.CRAMP,1.3)
	await Game.timeout(1.)
	await destroy_segments.call(true)
	
	
	playback.stop()
	
	await tile_board.settle_board()
	await tile_board.fill_board()
	

	_post_use()


func is_tile_selectable(tile: Tile) -> bool:
	return ( 
		on_first_tile or
		((tile not in tiles) and tile in tiles[-1].get_board_neighbors())
	)
