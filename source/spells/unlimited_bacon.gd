extends TileModifierSpell


var current_name := 3

func set_status_tooltips():
	status_tooltips = [TileEffect.SHIMMERING, TileEffect.WILDCARD,"epsilon"]

func get_title_context() -> Dictionary:
	current_name = (current_name + 1)%4
	shake.emit()
	return super()

func get_spell_name() -> String:
	return get_string_group().get_string("name_%d"%(current_name+1), get_tooltip_context())
	
func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	tile.set_face(
		["*",ProverbPalaceTileManager.EPSILON]
	)

func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable() and 
		!tile.has_effect(TileEffect.SHIMMERING) and 
		!("*" in tile.faces)
	)
