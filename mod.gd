@tool
extends Mod
class_name ProverbPalaceMod
#const MUTAGEN_BUBBLES = preload("uid://xd5bu6sw7c6k")


const SPELLS: Dictionary[String, String] = {
	PDA = "pda",
	PHOTO_ALBUM = "photo_album",
	
	
	DATAMOSH = "datamosh",
	BLENDER = "blender",
	BOOSTER_SHOT = "booster_shot",
	TOY_CAMERA = "toy_camera",
	MILK = "milk",
	ZIPTIES = "zipties",
	GAYDAR = "gaydar",
	COLD_CASE = "cold_case",
	CAT_TAIL = "cat_tail",
	BLT = "blt",
	DISSENTER_HOTLINE = "dissenter_hotline",
	SUBDOMAIN = "subdomain",
	LCD_TWEEZERS = "lcd_tweezers",
	DYNAMO = "dynamo",
	SOFTBOILED = "softboiled",
	BLOWOUT = "blowout",
	POCKET_SNAKE = "pocket_snake",
	VANILLA_ESSENCE = "vanilla_essence",
	HALO = "halo",
	SD_CARD = "sd_card",
	DISCOMBOBULATOR = "discombobulator",
}

var BASE_WEIGHT := 4.5
var PLAYTESTED_COEFF := .5
var UNPLAYTESTED_COEFF := 1.5
const UNCOMMON_COEFF := .5


var SPELL_CATEGORIES: Dictionary[String, Array] = {
	Globals.SPELL_CATEGORY.SUPPORT: [
		SPELLS.DATAMOSH,
		SPELLS.BOOSTER_SHOT,
		SPELLS.CAT_TAIL,
		SPELLS.DISSENTER_HOTLINE,
		SPELLS.LCD_TWEEZERS,
		SPELLS.DYNAMO,
		SPELLS.POCKET_SNAKE,
		SPELLS.VANILLA_ESSENCE,
		SPELLS.DISCOMBOBULATOR
	],
	Globals.SPELL_CATEGORY.OFFENSIVE: [
		SPELLS.MILK,
		SPELLS.GAYDAR,
		SPELLS.SUBDOMAIN,
		SPELLS.BLOWOUT,
		SPELLS.SD_CARD,
		SPELLS.HALO,
	],
	Globals.SPELL_CATEGORY.DEFENSIVE: [
		SPELLS.TOY_CAMERA,
		SPELLS.ZIPTIES,
		SPELLS.BLT,
		SPELLS.COLD_CASE,
		SPELLS.SOFTBOILED,
	],
	
	Globals.SPELL_CATEGORY.DIRECT_DEFENSE: [
		SPELLS.TOY_CAMERA,
		SPELLS.ZIPTIES,
		SPELLS.COLD_CASE,
	],
}


#static func _static_init():
	#print("trying my best")
	#Sounds.register_sounds(
		#{
			#DIMORPH={
				#SOUNDS = [
					#preload("res://mods/proverbpalace/overrides/sounds/dimorph/dimorph_flinch.wav"),
					#preload("res://mods/proverbpalace/overrides/sounds/dimorph/dimorph_flinch_parry.wav"),
					#preload("res://mods/proverbpalace/overrides/sounds/dimorph/dimorph_growl.wav"),
					#preload("res://mods/proverbpalace/overrides/sounds/dimorph/dimorph_gunkshot.wav"),
					#preload("res://mods/proverbpalace/overrides/sounds/dimorph/dimorph_xscissor_1.wav"),
					#preload("res://mods/proverbpalace/overrides/sounds/dimorph/dimorph_xscissor_2.wav"),
				#]
			#}
		#},
		#Sounds.SOUND_CONSTANTS,
		#Sounds.SOUND_GROUPS,
	#)
	#

func _ready() -> void:
	#CustomIntent.custom_status_intent_icons["mutagen"]=preload("uid://dukxvsrifradw")
	#update_remove_other_enemies()
	var do_playtest_weights = FileAccess.file_exists("res://mods/proverbpalace/BOOST_SPELL_WEIGHTS.yes")
	
	print_debug("Yay loaded Proverb Palace. Playtest weights file %sdetected"%("not " if !do_playtest_weights else ""))
	#if "dimorph" not in EnemyLoader.enemy_pools[0][0]:
		#EnemyLoader.add_enemy("dimorph",2,3,"res://mods/proverbpalace/arte/dimorph/miniface_dimorph.png")
	
	
	
	await Game.main_scene_loaded
	Game.main.game_state_updated.connect(_game_state_updated)

func _game_state_updated():
	#if Game.word_builder != null and !Game.word_builder.has_node("MutagenBubbles"):
		#var inst = MUTAGEN_BUBBLES.instantiate()
		#Game.word_builder.add_child(inst)
		#var word_holder = Game.word_builder.get_node("WordHolder")
		#word_holder.updated_tiles.connect(inst._on_word_holder_updated_tiles)
	pass
func _post_mods_loaded() -> void :
	pass


func get_options_save_data() -> Dictionary:
	return {}


func get_save_data() -> Dictionary:
	return {}


func get_run_save_data() -> Dictionary:
	return {}

func get_spell_ids() -> Array[String]:
	return namespace_ids(SPELLS.values())
	
func get_spell_pool(category: String = "") -> Dictionary[String, float]:
	var do_playtest_weights = FileAccess.file_exists("res://mods/proverbpalace/BOOST_SPELL_WEIGHTS.yes")
	
	if !do_playtest_weights:
		BASE_WEIGHT = 1.
		PLAYTESTED_COEFF = 1.
		UNPLAYTESTED_COEFF = 1.
	
	print_debug("PROVERB PALACE: FILLING SPELL POOL%s"%
		" USING PLAYTEST WEIGHTS" if do_playtest_weights else ""
	)
	
	var SPELL_POOL: Dictionary[String, float] = {
		SPELLS.TOY_CAMERA: BASE_WEIGHT,
		SPELLS.DATAMOSH: BASE_WEIGHT,
		SPELLS.CAT_TAIL: BASE_WEIGHT*PLAYTESTED_COEFF,
		SPELLS.GAYDAR: BASE_WEIGHT,
		SPELLS.BOOSTER_SHOT: BASE_WEIGHT*PLAYTESTED_COEFF,
		SPELLS.MILK: BASE_WEIGHT, #UNKILLED
		SPELLS.ZIPTIES: BASE_WEIGHT*UNPLAYTESTED_COEFF,
		SPELLS.COLD_CASE: BASE_WEIGHT,
		SPELLS.BLT: BASE_WEIGHT*UNCOMMON_COEFF,
		SPELLS.DISSENTER_HOTLINE: BASE_WEIGHT,
		SPELLS.SUBDOMAIN: BASE_WEIGHT,
		SPELLS.LCD_TWEEZERS: BASE_WEIGHT,
		SPELLS.DYNAMO: BASE_WEIGHT*UNPLAYTESTED_COEFF,
		SPELLS.BLOWOUT: BASE_WEIGHT,
		SPELLS.POCKET_SNAKE: BASE_WEIGHT,
		SPELLS.HALO: BASE_WEIGHT,
		SPELLS.SOFTBOILED: BASE_WEIGHT,
		SPELLS.DISCOMBOBULATOR: BASE_WEIGHT*UNPLAYTESTED_COEFF*0.,
		SPELLS.SD_CARD: 0.,
		SPELLS.VANILLA_ESSENCE: 0.,
		SPELLS.PDA: 0.,
		SPELLS.PHOTO_ALBUM: 0.,
		SPELLS.BLENDER: 0.,
	}
	
	var category_pool: Array = SPELL_CATEGORIES.get(category, [])
	var pool := SpellData.get_filtered_spell_pool(SPELL_POOL, category_pool)
	return namespace_dictionary_ids(pool)
