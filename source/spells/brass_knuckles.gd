extends TileModifierSpell
const ARCING_PROJECTILE = preload("res://source/effects/arcing_projectile.tscn")

func set_status_tooltips():
	status_tooltips = [{status=TileStatus.BRUISE,status_value=1}, "epsilon"]

func launch_dupe_of_tile(original_tile: Tile):
	var tile_face: TileFace = original_tile.tile_face.duplicate()
	
	main.add_child(tile_face)
	tile_face.global_position = original_tile.global_position
	
	
	
	
	

	var bounce_offset: = randf_range(64, 96)
	var direction: = randi_range(0, 1)
	var direction_sign: = -1 if direction == 0 else 1
	var dest = Vector2(tile_face.global_position.x + bounce_offset * direction_sign, 290)
	var projectile: ArcingProjectile = ARCING_PROJECTILE.instantiate()
	main.projectile_container.add_child(projectile)

	projectile.gravity = 800
	projectile.launch(original_tile.global_position, dest, 64)
	projectile.do_poof = false
	projectile.impacted.connect(tile_face.queue_free)
	projectile.look_at_direction = false
	projectile.angular_velocity = PI * 10
	projectile.angular_deceleration = PI * 18
	projectile.decelerate_to = PI * 2
	
	tile_face.reparent(projectile)
	
	tile_face.deboss_highlight_color = Globals.TILE_DEBOSS_COLOR.bruise[
		0 if original_tile.type == TileType.DAMAGE else 1
	]
	tile_face.faces = original_tile.faces
	tile_face.set_value(0)
	tile_face.set_statuses(original_tile.statuses)
	#tile_face.update_face(true)
	tile_face.update_visual()
	
	tile_face.get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(
		tile_face,"scale",Vector2.ONE*2.,2.
	)
	
	tile_face.z_index = 2000
	tile_face.position = Vector2(0, 0)
	tile_face.rotation = deg_to_rad(-90)

const FLASH_FX = preload("res://mods/proverbpalace/source/spells/flash_fx.tscn")
func create_flash_effect(tile: Tile) -> FlashFX:
	var flash := FLASH_FX.instantiate() as FlashFX
	flash.ready.connect(
		func():
			#flash.animation_player.speed_scale=  .75
			flash.modulate = Globals.COLORS.BRUISE
	)
	main.add_child(flash)
	flash.global_position = tile.global_position
	
	return flash


func _on_spell_paper_button_pressed(player_spell: PlayerSpell):
	
	cancel_selection()
	
	var sprite = player_spell.spell_sprite.duplicate()
	
	var bounce_offset: = randf_range(64, 96)
	var direction: = randi_range(0, 1)
	var direction_sign: = -1 if direction == 0 else 1
	var dest = Vector2(player_spell.spell_sprite.global_position.x + bounce_offset * direction_sign, 290)
	var projectile: ArcingProjectile = ARCING_PROJECTILE.instantiate()
	main.projectile_container.add_child(projectile)
	var offset = Vector2.ONE*16
	projectile.gravity = 1200
	projectile.launch(player_spell.spell_sprite.global_position+offset, dest, 64)
	projectile.do_poof = false
	projectile.impacted.connect(sprite.queue_free)
	projectile.look_at_direction = false
	projectile.angular_velocity = PI * 10
	projectile.angular_deceleration = PI * 18
	projectile.decelerate_to = PI * 2
	
	projectile.add_child(sprite)
	sprite.position = -offset
	
	sprite.link_spell(player_spell.spell)
	player_spell.spell.transform_spell(
		"proverbpalace:blt"
	)
	AudioManager.play_sound(Sounds.STOKER.SWING,randf_range(.8,.83))
	
	

func _use():
	
	var funcs_to_call = []
	
	(func ():
		await main.get_tree().process_frame
		for player_spell: PlayerSpell in (player).spell_container.player_spells:
			if "sock" in player_spell.spell.id.to_lower():
				player_spell.spell_paper.set_usable(
					true
				)
				var bound = _on_spell_paper_button_pressed.bind(player_spell)
				player_spell.spell_paper.enable_button()
				player_spell.spell_paper.button.pressed.connect(
					bound
				)
				funcs_to_call.append(
					func():
						player_spell.spell_paper.button.pressed.disconnect(
							bound
						)
				)
	).call()
	var choice = await player.get_selection(player.Selection.TILE, func(t): return is_tile_selectable(t))
	
	for f in funcs_to_call:
		f.call()
		
	
	if choice == null:
		_end_use()
		(charge_container.get_node("../../..") as SpellPaper).anim_player.stop()
		return


	if choice is Tile and is_tile_selectable(choice):
		await apply_to_tile(choice, choice, false, false)
	else:
		_end_use()

	if player.is_using_spell():
		_post_use()

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :

	if not is_preview:
		tile.animation.play("pressed",3.5)
		AudioManager.play_sound(Sounds.STOKER.SWING,randf_range(.8,.83),.35)
		AudioManager.play_sound(Sounds.GENERIC.HIT,1.5)
		#tile.add_poofcloud(Globals.COLORS.BRUISE)
		var flash := create_flash_effect(tile)
		flash.position += tile.get_local_mouse_position().clampf(-4.,4.)
		launch_dupe_of_tile(tile)
	tile.set_face("ԑ")
	tile.add_status(TileStatus.BRUISE)
	tile.clear_faceless_effects()



func is_tile_selectable(tile: Tile) -> bool:
	if tile == null:
		return false
	return !(tile.has_status(TileStatus.BRUISE) and tile.only_face_is("ԑ"))
