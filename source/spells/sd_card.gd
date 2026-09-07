extends TileModifierSpell

const SHIMMER_CHANCE := .75
const SD_CARD_EFFECT = preload("res://mods/proverbpalace/source/spells/sd_card_effect.tscn")

func set_status_tooltips():
	status_tooltips = [TileEffect.SHIMMERING, TileEffect.SLASHED, TileStatus.CRIT]

func make_sd_card_effect(tile: Tile) -> void:
	var effect := SD_CARD_EFFECT.instantiate() as SDCardEffect
	
	tile.tile_sprite.add_child(effect)
	
	await effect.apply
	
func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	if !is_preview:
		await make_sd_card_effect(tile)
	tile.add_status(TileStatus.CRIT)
	const faces = ["s","d"]
	if is_preview:
		tile.set_face("s?d")
	else:
		if rng.spell.randf() < SHIMMER_CHANCE:
			tile.set_face(faces)
		else:
			tile.set_slashed(faces)


func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable() and 
		!tile.has_harmful_status() and 
		!tile.has_effect(TileEffect.SHIMMERING) and 
		len(tile.face) == 1 and 
		tile.has_face()
	)
