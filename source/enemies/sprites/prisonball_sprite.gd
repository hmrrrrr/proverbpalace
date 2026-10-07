@tool
extends BattleUnitSprite

signal change_face

const SOUNDS := {
	PRISONBALL_VOX1= preload("res://mods/proverbpalace/sounds/prisonball/prisonball1.wav"),
	PRISONBALL_VOX2= preload("res://mods/proverbpalace/sounds/prisonball/prisonball2.wav"),
	PRISONBALL_VOX3= preload("res://mods/proverbpalace/sounds/prisonball/prisonball3.wav"),
	BOUNCE= preload("res://mods/proverbpalace/sounds/prisonball/prisonballbounce.wav")
}
const SOUND_REPLACEMENTS = [
	"FREEZER/BOUNCE","FREEZER/VOX_FREEZER"
]

static var last_vox := 1
@onready var p_ball: Sprite2D = $PBall

var playing_now := {}


const MAX_DRIBBLE_BREADTH := 20.

var current_max_dribble_breadth = 20.
@export var dribble_deviation: float :
	set(v):
		if p_ball: p_ball.position.x = v*current_max_dribble_breadth
		dribble_deviation = v

func reset_dribble_range() -> void:
	var rand = randf()
	rand = 1.-(1.-rand)*(1.-rand)
	current_max_dribble_breadth = rand*MAX_DRIBBLE_BREADTH*(-1.*signf(current_max_dribble_breadth))

func handle_sound(sound_name: String) -> void:
	if !anim_player.is_playing():
		return
	if sound_disabled:
		return
	playing_now[sound_name] = true
	match sound_name:
		"FREEZER/BOUNCE":
			if Engine.is_editor_hint():
				Sounds.refresh_sounds()
			AudioManager.play_sound(
				SOUNDS.BOUNCE
			)
		"FREEZER/VOX_FREEZER":
			if Engine.is_editor_hint():
				Sounds.refresh_sounds()
			AudioManager.play_sound(
				SOUNDS["PRISONBALL_VOX%d"%last_vox]
			)
			last_vox = wrapi(last_vox+1,1,4)
		_:
			super(sound_name)
			playing_now[sound_name] = false
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	playing_now[sound_name] = false

func is_idling():
	return anim_player.current_animation == "idle"
