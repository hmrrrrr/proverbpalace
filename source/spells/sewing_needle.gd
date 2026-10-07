extends TileModifierSpell

var face = "s"

func load_save_data(save):
	super(save)
	
	face = save.applied_face
func get_save_data():
	var s = super()
	s.applied_face = face

func can_extend_face(tile_face) -> bool:
	return (3 - len(tile_face)) >= len(face)

func get_tooltip_context():
	return {face = face}

func apply_to_tile(tile: Tile, real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	var prev_face := real_tile.face
	tile.set_current_face(real_tile.face + face)
	
	if !is_preview:
		face = prev_face
		description_updated.emit()
	

func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable() and 
		!tile.has_effect(TileEffect.SHIMMERING) and 
		tile.has_face() and
		can_extend_face(tile.face)
	)
