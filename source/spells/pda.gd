extends Spell


var minigame_scene = load("res://mods/proverbpalace/source/minigames/pda_minigame.tscn")
var minigame: PDAMinigame = null


func _use():
	
	start_minigame()
	await minigame.finished
	await end_minigame()
	
	_post_use()


func start_minigame():
	minigame = minigame_scene.instantiate()
	minigame.start()
	minigame.appear()


func end_minigame():
	await minigame.disappear()
	minigame.end()
