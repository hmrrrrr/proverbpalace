extends Node
class_name ProverbPalaceGamestateManager

const MANUAL_SQUISHER = preload("res://mods/proverbpalace/source/effects/manual_squisher.tscn")


var connected_player := false
var connected_tile_board := false

var transitioning_from_player_to_enemy_turn := false

func _on_player_bruise_changed():
	var player: Player = Game.player
	
	
	if Game.word_builder.bruise > 0:
		
		var intent_container = player.intent_container
		
		while true:
			if intent_container.get_intent_instance(Globals.Intent.PLAYER_BRUISE,{}):
				break
			await get_tree().process_frame
			
	else:
		await get_tree().process_frame
	
	if ProverbPalaceTileManager.stored_counterattack > 0:
		
		player.intent_container.reset_intents()
		player.display_intent()
		ProverbPalaceMod.tile_manager.update_counter_intent(
				player.intent_container,
				ProverbPalaceCustomIntent.COUNTER_INTENT,{damage=ProverbPalaceTileManager.stored_counterattack},null,true
			)
		player.intent_container.update_intents()

const COUNTER_PUNCH = preload("res://mods/proverbpalace/source/effects/particle/counter_punch.tscn")

func create_counter_punch_effect(enemy: Enemy) -> CounterPunchEffect:
	var inst := COUNTER_PUNCH.instantiate() as CounterPunchEffect
	
	Game.main.add_child(inst)
	
	inst.global_position.y = enemy.sprite.hit_marker.global_position.y
	inst.global_position.x = enemy.sprite.global_position.x
	
	return inst


func _on_player_animation_event(event_name: String):
	if "editor_star" in event_name:
		var player:Player = Game.player
		var enemy:Enemy = Game.enemy
		
		if !enemy.is_defeated and ProverbPalaceTileManager.stored_counterattack > 0:
			
			
			var anim_player = enemy.sprite.anim_player
			anim_player.create_tween().set_ease(Tween.EASE_OUT).tween_property(
				anim_player,"speed_scale",.0,.2
			)
			
			
			await Game.timeout(0.16)
			#
			#if transitioning_from_player_to_enemy_turn:
				#await player.recomposed
			#
			
			
			var punch := create_counter_punch_effect(enemy)
			AudioManager.play_sound(
				preload("res://sounds/paddlers/paddleswing.wav"),1.,.36
			)
			await punch.punch
			anim_player.create_tween().set_ease(Tween.EASE_IN).tween_property(
				anim_player,"speed_scale",1.,.2
			)
			if enemy.health - enemy.get_adjusted_damage_amount(ProverbPalaceTileManager.stored_counterattack) <= 0:
				var enemy_script :=  enemy.get_script() as Script
				(enemy_script).reload(true)
				enemy.sprite.anim_player.play("RESET")
				enemy.sprite.anim_player.advance(0)
			AudioManager.play_sound(
				preload("res://mods/proverbpalace/sounds/prisonball/prisonballbounce.wav"),1.,1.
			)
			
			enemy.add_child(MANUAL_SQUISHER.instantiate())
			await player.deal_damage(
				enemy,
				ProverbPalaceTileManager.stored_counterattack,
				Globals.DamageType.DIRECT,
				true,true)
			if enemy.is_defeated:
				player.recompose()
				player.is_flinching = false
				player.is_recomposing = false
				
				if enemy.damage_received != 0:
					await Game.main.end_enemy_turn()

func _on_player_turn_started() -> void:
	ProverbPalaceTileManager.stored_counterattack = 0
	var player: Player = Game.player
	player.bruise_changed.emit()
	

func init_player(player: Player) -> void:
	if !player.is_node_ready():
		await player.ready
	player.sprite.event_emitted.connect(
		_on_player_animation_event
	)
	player.bruise_changed.connect(
		_on_player_bruise_changed
	)
	player.turn_started.connect(
		_on_player_turn_started
	)
	player.recomposed.connect(
		_on_player_recomposed
	)

func _on_player_recomposed():
	transitioning_from_player_to_enemy_turn = false

func _on_tile_board_turn_ended():
	transitioning_from_player_to_enemy_turn = true


func init_tile_board(tile_board: TileBoard):
	tile_board.turn_ended.connect(_on_tile_board_turn_ended)
	
func _on_game_state_updated() -> void:
	var enemy: Enemy = Game.enemy
	var player: Player = Game.player
	if (enemy == null or enemy.is_defeated) and ProverbPalaceTileManager.stored_counterattack > 0:
		ProverbPalaceTileManager.stored_counterattack = 0
		player.bruise_changed.emit()
func _ready() -> void:
	if !connected_player:
		init_player(Game.player)
	
	if !connected_tile_board:
		init_tile_board(Game.tile_board)
	Game.main.game_state_updated.connect(
		_on_game_state_updated
	)
	

func _on_node_added(node: Node):
	if node is Player:
		init_player(node)
		connected_player = true
	if node is TileBoard:
		init_tile_board(node)
		connected_tile_board = true
	
