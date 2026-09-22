extends TileModifierSpell

func set_status_tooltips():
	status_tooltips = ["mutagen"]

const POOFCLOUD = preload("res://source/effects/poofcloud_small.tscn")
const BIG_POOFCLOUD = preload("res://source/effects/poofcloud.tscn")
const MUTAGEN_POOFCLOUD_MATERIAL = preload("res://mods/proverbpalace/source/effects/mutagen_poofcloud_material.tres")
const MILKSPILL = preload("res://mods/proverbpalace/sounds/milkspill.wav")

static func create_mutagen_poofcloud(tile: Tile, big := false):
	AudioManager.play_sound(Sounds.GENERIC.APPLY_STATUS)
	var poofcloud: Node2D = null
	if big:
		poofcloud = BIG_POOFCLOUD.instantiate()
	else:
		poofcloud = POOFCLOUD.instantiate()

	Game.main.add_child(poofcloud)
	poofcloud.material = MUTAGEN_POOFCLOUD_MATERIAL
	
	poofcloud.global_position = tile.global_position

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	tile.add_status("mutagen")
	
	if is_preview:
		return
	
	AudioManager.play_sound(Sounds.SPELLS.SODA_CAN,1.,1.)
	var neighbor_tiles = tile.get_board_neighbors()
	rng.spell.shuffle(neighbor_tiles)
	create_mutagen_poofcloud(tile)
	for neighbor in neighbor_tiles:
		if not neighbor.has_status(TileStatus.DEFAULT):
			continue

		await Game.timeout(0.16)

		neighbor.add_status("mutagen")
		create_mutagen_poofcloud(neighbor)
		return


func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable() and 
		!tile.has_harmful_status() and 
		!tile.has_effect(TileEffect.SHIMMERING) and 
		tile.has_face() and 
		!tile.has_effect(TileEffect.POSITIVE_FACE) and 
		!tile.has_status("mutagen")
	)
