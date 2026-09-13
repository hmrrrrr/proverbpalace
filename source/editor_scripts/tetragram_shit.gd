@tool
extends EditorScript



func _run() -> void:
	
	var game_dictionary = ResourceLoader.load("res://words/compiled.res", "", ResourceLoader.CACHE_MODE_IGNORE)
	
	var words = game_dictionary.words.words
	for tetragram in Letters.TETRAGRAMS:
		if tetragram in words:
			print(tetragram)
