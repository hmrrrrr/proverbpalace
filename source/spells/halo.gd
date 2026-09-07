extends TileModifierSpell

const FOREIGN_1 = preload("res://sounds/freezer/foreign1.wav")
var mimicking_spell_id := ""
const HALO_EFFECT = preload("res://mods/johnboat/source/spells/halo_effect.tscn")

func set_status_tooltips():
	status_tooltips = [TileStatus.ETERNAL, TileStatus.HOLE]

func _ready() -> void:
	Game.player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed() -> void:
	if Game.player.health <= 3 and Game.player.health > 0:
		add_charge(1)

func create_halo_effect(tile:Tile) -> HaloEffect:
	var inst := HALO_EFFECT.instantiate() as HaloEffect
	main.add_child(inst)
	inst.global_position = tile.global_position
	
	return inst

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	tile.apply_hole( not is_preview)
	tile.add_status(TileStatus.ETERNAL)
	if not is_preview:
		AudioManager.play_sound(FOREIGN_1,1.,.7,)
		create_halo_effect(tile)
		tile.add_poofcloud(tile.get_color())


func is_tile_selectable(tile: Tile) -> bool:
	return (
		!tile.has_status(TileStatus.HOLE)
	)
