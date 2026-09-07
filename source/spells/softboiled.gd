extends TileModifierSpell

func set_status_tooltips():
	status_tooltips = [TileStatus.SPICY, TileStatus.CANDY]

const EGGSHELL = preload("res://mods/proverbpalace/source/effects/eggshell.tscn")
const EGG_CRACK = preload("res://mods/proverbpalace/sounds/egg_crack.wav")
const EGG_FLUID_TRAIL = preload("res://mods/proverbpalace/source/effects/egg_fluid_trail.tscn")


func do_egg_crack_effect(tile: Tile):
	AudioManager.play_sound(EGG_CRACK)
	#AudioManager.play_sound(Sounds.GENERIC.APPLY_STATUS)
	tile.animation.play("shake",-1,1.5)
	
	var eggshell_a: EggshellEffect
	var eggshell_b: EggshellEffect
	for i in 2:
		var effect := EGGSHELL.instantiate() as EggshellEffect
		
		effect.atlas = tile.tile_sprite.base_sprite.texture
		effect.atlas_frame = tile.tile_sprite.base_sprite.frame
		
		effect.mask_frame = i
		effect.bound_node = tile.tile_sprite
		main.add_child(effect)
		effect.global_position = tile.global_position
		
		if i == 0:
			eggshell_a = effect
		else:
			eggshell_b = effect
			
	var create_trail = func(width: float, offset: Vector2):
		var trail := EGG_FLUID_TRAIL.instantiate() as EggFluidTrail
		tile.add_child(trail)
		trail.width = width
		trail.position = offset
		trail.offset = offset
		trail.eggshell_a = eggshell_a
		trail.eggshell_b = eggshell_b
	
	for i in range(1,7):
		create_trail.call(i,Vector2(randf_range(-3,3),randf_range(-3,3)))
	
	const prebounce := .05
	await Game.timeout(EggshellEffect.CRACK_DELAY-prebounce)
	tile.animation.play("bounce",-1,1.2)
	await Game.timeout(prebounce)
	
	tile.add_poofcloud(tile.get_poof_color())

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	if tile.has_status(TileStatus.COAL):
		if !is_preview:
			do_egg_crack_effect(tile)
		tile.add_status(TileStatus.CANDY)
		tile.set_face("99")
	else:
		tile.add_status(TileStatus.SPICY)
		
		if !is_preview:
			tile.add_poofcloud(tile.get_poof_color())
		
		


func is_tile_selectable(tile: Tile) -> bool:
	return (
		!tile.has_harmful_status() and 
		tile.has_face() or tile.has_status(TileStatus.COAL)
	)
