extends Enemy


const PrisonballProjectile = preload("res://mods/proverbpalace/source/effects/prisonball_projectile.tscn")
var prisonball_projectile = null

var explode_animation: = "explode"
var explode_quickly_animation: = "explode_quickly"

@onready var prisonball_sprite = $Sprite / PBall
@onready var face_sprite: Sprite2D = $Sprite / PBall / SubViewport / PBallPivot / BadIdea

const FACES = [
	preload("res://mods/proverbpalace/arte/enemies/bad_idea.png"),
	preload("res://mods/proverbpalace/arte/enemies/bad_idea2.png"),
]

var face_index = 0 :
	set(v):
		face_index = v%len(FACES)

func _get_health_scaling():
	return [50, 54, 58, 76]

func _ready():
	sprite.change_face.connect(
		_change_face
	)
	super()

func update_face():
	face_sprite.texture = FACES[face_index]

func get_save_data():
	var s = super()
	s.face_index = face_index
	return s

func load_save_data(save):
	super(save)
	face_index = save.face_index

func _change_face():
	face_index += 1
	update_face()

func _init():
	id = "prisonball"
	next_move = "sandbag"

	moves = {
		rubberize = {
			counter = 2, 
			next = "sandbag", 
		}, 
		sandbag = {
			damage = {
				0: 3, 
				1: 4, 
				2: 5, 
				3: 6, 
			}, 
			next = "dribble", 
		}, 
		dribble = {
			damage = {
				0: 6, 
				1: 7, 
				2: 8, 
				3: 9, 
			}, 
			next = "dribble", 
		}, 
	}


func _process(_delta):
	sprite.hit_marker.global_position = prisonball_sprite.global_position
	sprite.hit_marker.global_position.x -= 8


func display_intent():
	var count = 1
	if next_move == "dribble":
		count = 2 + times_performed_move.dribble
	
	add_intent(Intent.ATTACK, {damage = moves[next_move].damage,count=count})
	add_intent(Intent.CONVERT_STATUS, {statuses = ["counter", TileEffect.WILDCARD], count = moves.rubberize.counter})


func animate_flinch(_damage):
	AudioManager.play_sound(Sounds.FREEZER.FLINCH)

	var start = prisonball_sprite.global_position
	var dest = Vector2(global_position.x + 160, global_position.y)
	var height = 35

	clear_intent()
	await launch(start, dest, height)

	anim_player.play("appear")
	prisonball_sprite.show()

	if main.is_player_turn:
		await anim_player.animation_changed
		update_intents()


func animate_flinch_lethal():
	AudioManager.play_sound(Sounds.FREEZER.FLINCH)

	health_bar.disappear()

	var start = prisonball_sprite.global_position
	var dest = Vector2(global_position.x + 60, global_position.y - 16)
	var height = 60

	await launch(start, dest, height, false)
	Game.screenshake(8, 0.24)

	AudioManager.play_sound(Sounds.FREEZER.BOUNCE)

	await relaunch(
		prisonball_projectile.global_position, 
		Vector2(global_position.x - 16, global_position.y - 8), 
		40)
	Game.screenshake(20, 0.32)

	prisonball_projectile.queue_free()
	prisonball_projectile = null

	anim_player.play("die")
	await anim_player.animation_finished
	await Game.timeout(0.5)


func launch(start, dest, height, free_on_impact = true):
	prisonball_projectile = PrisonballProjectile.instantiate()

	anim_player.stop()

	main.add_child(prisonball_projectile)

	post_launch()

	prisonball_projectile.free_on_impact = free_on_impact

	prisonball_projectile.launch(start, dest, height)
	await prisonball_projectile.impacted

	if free_on_impact:
		prisonball_projectile = null


func relaunch(start, dest, height):
	prisonball_projectile.launch(start, dest, height)
	await prisonball_projectile.impacted


func post_launch():
	pass


func rubberize():
	

	var apply_to = get_tiles({
		amount = moves.rubberize.counter, 
		effect_priority = EFFECT_PRIORITY.STATUS_AND_FACE_AVOID_PLASTIC, 
		exclude_letters = ["*"]
	})

	for tile: Tile in apply_to:
		var pause = randf_range(0.04, 0.08)
		await Game.timeout(pause)
		tile.remove_face_statuses()
		tile.set_face("*")
		tile.add_status("counter")
		tile.set_type(TileType.DEFENSE)
		tile.animation.play("bounce")
		AudioManager.play_sound(
			Sounds.SPELLS.SWITCH
		)


func sandbag():
	await dribble(1)

func dribble(count: int = 2 + times_performed_move.dribble):
	
	if "appear" in anim_player.current_animation:
		anim_player.clear_queue()
		await anim_player.animation_finished
	else:
		await sprite.animation_looped
	
	for i in range(count):
		var is_final_explosion := i == count-1
		
		var animation := explode_animation if is_final_explosion else explode_quickly_animation
		anim_player.play(animation)
		
		await sprite.hit
		hit_player(moves[next_move].damage, is_final_explosion)
		if is_final_explosion:
			rubberize()
		Game.screenshake(10 if is_final_explosion else 5, 0.32 if is_final_explosion else .16)
		
		await pend_animation_stopped(animation)
		

	await pend_animation_stopped(explode_animation)

func apply_fish(tile: Tile, fish: Fish) -> void :
	if fish.rng.randf() <= 0.1:
		tile.add_status("counter")
