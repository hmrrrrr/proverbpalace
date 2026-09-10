extends ScrewStatus

func apply(_turns: int = -1):
	super()
	tile.tile_sprite.screw.hframes = 4

func update_status_visual() -> void :
	tile.tile_sprite.screw.hframes = 4
	tile.tile_sprite.screw.visible = true
	tile.tile_sprite.screw.frame = 1 if turns == 0 else 0

func is_space() -> bool:
	tile.tile_sprite.screw.hframes = 4
	var output := super()
	if output:
		var mult = (Game.main.word_builder.get_tile_multiplier(tile))
		if mult < 0:
			tile.tile_sprite.screw.frame = 3
		elif mult > 1:
			tile.tile_sprite.screw.frame = 2
		else:
			tile.tile_sprite.screw.frame = 1
	return output

func update_frame() -> void:
	super()
	
	
