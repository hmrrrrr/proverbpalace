extends Spell

const SOUNDS = {
	GAYDARSFX = preload("res://mods/proverbpalace/sounds/gaydarsfx.wav")
	
}

func get_preview_title(_tile):
	var group: = get_string_group()
	if group.has_string("preview_title"):
		return group.get_string("preview_title", get_tooltip_context())
	else:
		return StringManager.get_string("spell/default_preview_title")

func set_status_tooltips():
	status_tooltips = [{status = TileStatus.GAY}]




func get_preview_description(_tile):
	var group: = get_string_group()
	if group.has_string("preview_description"):
		return group.get_string("preview_description", get_tooltip_context())
	else:
		return ""


func has_special_tile_tooltip():
	return true

func generate_tile_tooltip(tile: Tile, tooltip: GameTooltip) -> void :
	
	var preview_tile = tile_board.create_preview_tile(tile)
	preview_tile.add_status(TileStatus.CRIT)
	tooltip.add_subtooltip(
		get_preview_title(tile), 
		"", 
		preview_tile, 
		get_preview_description(tile)
	)


func is_tile_selectable(tile: Tile) -> bool:
	return (not tile.has_harmful_status()) and (not tile.has_status(TileStatus.CRIT)) and (not tile.has_status(TileStatus.GAY))

func _use():
	var selected_tile := await get_selection()
	
	if selected_tile == null:
		_end_use()
		return

	var row = selected_tile.get_coord().y
	var col = selected_tile.get_coord().x

	var yuri_target_tiles = get_tiles({
		rows = [row], 
		sorted = true,
		#exclude_tiles = [selected_tile]
	})
	
	if randi()%2==0:
		yuri_target_tiles.reverse()
	
	var yaoi_target_tiles = get_tiles({
		columns = [col], 
		sorted = true,
		#exclude_tiles = [selected_tile]
	})
	if randi()%2==0:
		yaoi_target_tiles.reverse()

	if yaoi_target_tiles.is_empty() and yuri_target_tiles.is_empty():
		selected_tile.animation.play("shake")
		_end_use()
		return
	
	
	
	var apply_to_group := func(target_tiles: Array[Tile],type: TileType):
		const total_duration := 0.12*4
		var individual_duration := total_duration / float(len(target_tiles))
		var tile_count := len(target_tiles)
		
		var pitch_lerp := 0.
		
		var MIN_PITCH := randf_range(.8,.9)
		var MAX_PITCH := randf_range(1.1,1.2)
		
		if type == TileType.DEFENSE:
			MIN_PITCH -= .3
		else:
			MAX_PITCH += .3
		for tile in target_tiles:
			if tile != selected_tile:
				tile.set_type(type)
				tile.add_status(TileStatus.GAY)
				tile.add_poofcloud(Globals.COLORS.CHASER_PINK)
			elif type != selected_tile.type:
				continue
			else:
				tile.add_status(TileStatus.CRIT)
			
			tile.animation.play("bounce")
			
			AudioManager.play_sound(
				SOUNDS.GAYDARSFX,
				lerp(MIN_PITCH,MAX_PITCH,pitch_lerp),.8
			)
			
			await Game.timeout(individual_duration)
			if (tile_count > 1):
				pitch_lerp += 1./(tile_count-1)

	apply_to_group.call(yaoi_target_tiles,TileType.DEFENSE)
	await apply_to_group.call(yuri_target_tiles,TileType.DAMAGE)
	
	
	_post_use()
