extends TileModifierSpell
class_name BoosterShot

func set_status_tooltips():
	status_tooltips = [TileStatus.POISON]

const SHOTS = ["x*", "z*", "*j", "*q"]
var cycle_progress := 0
const BANDAGE_EFFECT_INSTANCE = preload("res://mods/proverbpalace/source/spells/bandage_effect_instance.tscn")
const BOOSTER_SHOT_USE = preload("res://mods/proverbpalace/sounds/booster_shot_use.wav")

func increment_cycle() -> void:
	cycle_progress = (cycle_progress+1)%len(SHOTS)
	description_updated.emit()

func get_displayed_cycle() -> String:
	var list = (SHOTS.slice(cycle_progress) if cycle_progress < len(SHOTS)-1 else []) + SHOTS.slice(0,cycle_progress)
	#list = list.slice(0,3)
	return "→".join(list)
	
func get_tooltip_context():
	return {cycle = get_displayed_cycle(), current_face = get_current_applied_face()}

func get_current_applied_face() -> String:
	return SHOTS[cycle_progress] 

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :

	var face_to_apply = SHOTS[cycle_progress]
	if not is_preview:
		
		AudioManager.play_sound(BOOSTER_SHOT_USE,1,2.5)
		var effect := BANDAGE_EFFECT_INSTANCE.instantiate() as BandageEffectInstance
		tile.tile_sprite.base_sprite.add_child(effect)
		await effect.applied
		increment_cycle()
		tile.animation.play("bounce")
		var c := Globals.COLORS.POISON
		c.a /= 2.
		tile.add_poofcloud(c)
	tile.add_status(TileStatus.POISON)
	tile.set_face(face_to_apply)

func get_save_data():
	var save = super.get_save_data()
	save["booster_cycle_progress"] = cycle_progress
	return save


func load_save_data(save):
	super.load_save_data(save)
	cycle_progress = save.booster_cycle_progress
	description_updated.emit()

func is_tile_selectable(tile: Tile) -> bool:
	return (
		not (
			tile.has_status(TileStatus.POISON)
			and tile.only_face_is(get_current_applied_face())
		)
	)
