extends Spell
class_name Datamosh

const DEBUG_PRINT_PIC = """\
             ██                                            
         █████████████████                ████████         
       ███████████████████             █████████████       
     ███████████████▓▓▓▓▓▓             █████▓▓████████     
     ███████████████▒▒▒▒▒▒██           ██▓▓▓▓▓████████     
    █████████▓▓██▒▒▒▒▒▓▓▒▒██████       ▓▓▓▓▓▓▓▒▒▒▒████     
    ████▓▓▓▓▓▒▒░░░░░░░░░░░███████    ██▒▒▒▓▓▒▒░░▒▒████     
    ██▓▓▓▓▓░░▒▒▒▒▒▒▒      ▒▒▒██████████▒▒▓▒▒▒▒░░▒▒████     
  ████▓▓▓▒▒▒▒░░▒▒▒▒▒      ▒▒▒▒▒██████████░░▒▒▒░░▒▒████     
  ████▓▓▓▒▒▒▒░░░░░░░      ▒▒█████████▒▒▓▒▒▒░░░▒▒▒▒████     
  ████▓▓▓▒▒██▓▓░░░░░        ▒▓███████▒▒▒▒▒▒░░░▒▒▒▒████     
  ████▓▓▓▒▒██▓▓▓▓░░░    ▓▓    ▓▓▓▓▓▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒████     
  ████▓▓▓▒▒▒▒░░▓▓░░░    ▓▓   ░▒▒▒▒▒████▒▒▒▓▓▓▓▒▒▒▒████     
  ████▓▓▓██▒▒░░░░░░░           ▒▒▒▒████▓▒▒▒░░░▒▒▒▒████     
  ██████▓████▓▓░░░░░      ▓▓▒  ▒▒▒▒████▒▒▓▒░░░▒▒▒▒████     
  ███████████▓▓▓▓░░░    ▓▓▓▓▒  ▒▒▒▒████▒▒▒▓▓▓▓▒▒▒▒████     
    ██         ▓▓░▓▓▓▓  ▓▓   ░▒▒▒▒▒████████▓▓▓▒▒▓▓████     
     ████████▓▓▓▓▓▓▓▓▓▓▓▓▓  ▒▒▒▒▒▒▒████████▓▓▓████████     
         ███████████▒▒▒▒▒▒▓▓▒▒▒▒▒██████████▓▓▓████████     
       ███████████████████▓▓██████████████████████████     
     █████████████████████▓▓█████    ████▓████████████     
     ████████████▒▒▒░░▒▒██▒▓████       ▓▓▓████▓▓▒▒████     
    █████████▒▒▒▒▒▒▒░░░░░░███████    ██▓▓▓▓▓▒▒▒▒▒▒████     
    ███████▓▓▒▒▒▒▒▒▒░░░░░░██▒██████████▓▓▓▒▒▒▒▒▒▒▒████     
  █████████▓▓▒▒▒▒▒▒▒░░░░░░██▒▒▒██████████▒▒▒▒▒▒▒▒▒████     
  ███████▒▒▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████▒▒▒▒▒▒▒▒▒▒▒▒▒████     
    ██████████████████████░░▓▒▒▒▒████▒▒███████████████     
     █████████████████████░░░▓▓▓▓▓▓▓▓▓▓███████████████     
                          ▒▒▒▒▒████████                    
                          █████████████   
"""

const CHARS_BY_RARITY = """\
qjxzwkvfybhgmp9udcl5otnrais8e24367\
"""
var current_frame := 0

var post_fakeout_charge := 0
var faking_out := true

func get_tooltip_context():
	return {fakeout = faking_out}

func load_save_data(save):
	super(save)
	faking_out = save.faking_out
	post_fakeout_charge = save.post_fakeout_charge

func get_save_data():
	var save = super.get_save_data()
	save.faking_out = faking_out
	save.post_fakeout_charge = post_fakeout_charge
	return save

func on_hover():
	if player.is_using_spell():
		return
		
	switch_state()
	frame_updated.emit()

func get_fucky_null_string() -> String:
	var base_string = get_string_group().get_string("null", get_tooltip_context()) + "​" # < = ZERO-WIDTH SPACE
	
	var t = inverse_lerp(0,MAX_NULLS_COUNT,nulls_count)
	
	
	var index = roundi(lerp(0,len(base_string)-3,t))
	
	
	
	return base_string.substr(0,index).to_upper() + base_string.substr(index)

func get_description() -> String:
	if !doing_nulling_animation:
		return super()
	return get_fucky_null_string().repeat(nulls_count)


func get_label() -> String:
	if !doing_nulling_animation:
		return super()
	return get_fucky_null_string().repeat(nulls_count/8+1)
func get_spell_name() -> String:
	if !doing_nulling_animation:
		return super()
	return get_fucky_null_string().repeat(nulls_count/8+1)
	

var MAX_NULLS_COUNT := 78
var nulls_count := 1
var doing_nulling_animation := false
var null_slowly := false

var last_tooltip: GameTooltip
func generate_player_spell_base_tooltip(tooltip: GameTooltip) -> void :
	
	super(tooltip)
	
	last_tooltip = tooltip

func generate_player_spell_tooltip(tooltip: GameTooltip) -> void:
	if !doing_nulling_animation:
		super(tooltip)
	else:
		generate_player_spell_base_tooltip(tooltip)

func switch_state():
	if faking_out and !doing_nulling_animation:
		doing_nulling_animation = true
		var playbacks: Array[AudioManager.SoundPlayback]
		var coeff := 1. if !null_slowly else 3.
		MAX_NULLS_COUNT *= 2 if null_slowly else 1
		for i in range(MAX_NULLS_COUNT):
			var t: float = inverse_lerp(0,MAX_NULLS_COUNT,i)
			nulls_count = i+1
			description_updated.emit()
			if i%4 == 0:
				playbacks.append(AudioManager.play_sound(
					SOUNDS["DATAMOSH_VAR%d"%[1,2].pick_random()],lerpf(.8,1.75,t)
				))
			
			if last_tooltip:
				last_tooltip.reset()
				generate_player_spell_tooltip(last_tooltip)
			await Game.timeout(lerpf(0.01*coeff,0.001,t))
		AudioManager.play_sound(SOUNDS.DATAMOSH)
		if last_tooltip:
			last_tooltip.reset()
		for playback in playbacks:
			playback.stop()
		doing_nulling_animation = false
		
		faking_out = false
		shake.emit()
		max_charge = post_fakeout_charge
		charge = post_fakeout_charge
		_update_state()
		if last_tooltip:
			generate_player_spell_tooltip(last_tooltip)
	else:
		current_frame = (current_frame + randi_range(1,2))%3
		if randf() < .13:
			current_frame = randi_range(3,5)
		if randf() < .75:
			shake.emit()
	
func _update_state():
	frame_updated.emit()
	description_updated.emit()
	charge_updated.emit()
	charge_container.update_max_charge(true)

func _first_spawn(is_transform: = false) -> void:
	super(is_transform)
	post_fakeout_charge = max_charge
	print(post_fakeout_charge)
	if charge_character in "e24" or has_curse(CURSE.ESOTERIC):
		post_fakeout_charge = 1
	elif (charge_character not in "9udcl5") or rng.charge.randf() < .5:
		post_fakeout_charge = 2
	
	max_charge = 0
	if charge_container:
		charge_container.update_max_charge(false)
	delayed_relief()
	
func delayed_relief():
	await Game.timeout(10)
	
	if faking_out:
		null_slowly = true
		on_hover()

func set_status_tooltips():
	status_tooltips = [TileStatus.CURSED,TileEffect.NUMBER]

func get_hv_frames() -> Vector2i:
	return Vector2i(8,1)

func get_frame() -> int:
	if faking_out:
		return 7
	
	return current_frame

func has_valid_word() -> bool:
	var words: WordList = word_builder.get_words()
	return word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1

func get_target_tiles():
	return word_builder.tiles.duplicate()

const SOUNDS = {
	DATAMOSH=preload("res://mods/proverbpalace/sounds/datamosh.wav"),
	DATAMOSH_VAR1=preload("res://mods/proverbpalace/sounds/datamosh1.wav"),
	DATAMOSH_VAR2=preload("res://mods/proverbpalace/sounds/datamosh2.wav"),
	DATAMOSH_VAR3=preload("res://mods/proverbpalace/sounds/datamosh3.wav"),
	DATAMOSH_VAR4=preload("res://mods/proverbpalace/sounds/datamosh4.wav"),
	KITTYTILE = preload("res://mods/proverbpalace/sounds/tiles/kittytile.wav")
}
const DATAMOSH_EFFECT = preload("res://mods/proverbpalace/source/datamosh/datamosh_effect_instance.tscn")


static func get_corresponding_numbers(face: String) -> String:
	
	var new_face = ""
	for letter in face:
		var found = false
		for number in Letters.NUMPAD_CHARACTERS.keys():
			var corresponding_letters = Letters.NUMPAD_CHARACTERS[number]
			if letter in corresponding_letters:
				new_face += (number)
				found = true
		
		if !found:
			new_face += letter
	
	return new_face

static func set_tile_face_to_corresponding_numbers(tile: Tile):
	if len(tile.faces) > 1:
		var faces = tile.faces.duplicate()
		for i in range(len(faces)):
			tile.set_face_at(i,get_corresponding_numbers(faces[i]))
	
	elif len(tile.tile_face.slashed_faces) != 0:
		var faces = tile.tile_face.slashed_faces.duplicate()
		for i in range(len(faces)):
			faces[i] = get_corresponding_numbers(faces[i])
		tile.set_slashed(faces)
	else:
		tile.set_face(get_corresponding_numbers(tile.face))

func _use():
	if not has_valid_word():
		_end_use()
		return

	AudioManager.play_sound(SOUNDS.DATAMOSH)

	var apply_to = get_target_tiles()
	rng.spell.shuffle(apply_to)
	var last_effect: GenericTileEffect
	for tile: Tile in apply_to:
		if is_tile_selectable(tile):
			
			var is_kitty: bool = tile.has_status(TileStatus.ASH)
			if is_kitty:
				for status in tile.get_statuses():
					if status.id == TileStatus.ASH or status.id == TileStatus.CURSED:
						is_kitty = status.get("kitty")
			
			var do_curse = true#!tile.has_status(TileStatus.CRIT)
			
			var inst := DATAMOSH_EFFECT.instantiate() as GenericTileEffect
			inst.do_play_sound = func():
				if is_kitty:
					AudioManager.play_sound(SOUNDS.KITTYTILE,0.55,.1)
				else:
					AudioManager.play_sound(
						SOUNDS["DATAMOSH_VAR%d"%randi_range(1,4)],randf_range(0.5,1.5)
					)
				set_tile_face_to_corresponding_numbers(tile)
			inst.frame_coords = tile.tile_sprite.base_sprite.frame_coords
			tile.tile_sprite.add_child(inst)
			inst.atlas = tile.tile_sprite.base_sprite.texture
			inst.dont_change = !do_curse
			inst.bounce.connect(
				func():
					tile.animation.play("shake"))
			await Game.timeout(0.05)
			
			if do_curse:
				tile.add_status(TileStatus.CURSED,{kitty=is_kitty})
				
				
				
			last_effect = inst
		else:
			tile.animation.play("shake")
	
	await last_effect.effect_finished
	_post_use()




func is_usable():
	return super.is_usable() and has_valid_word() and any_tile_selectable(get_target_tiles())


func is_tile_selectable(tile: Tile) -> bool:
	if randf() < .3:
		frame_updated.emit()
	return tile.has_face()
