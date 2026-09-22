@tool
extends EditorScript

const illegal_characters = " '.,-"

func _run() -> void:
	run_through_enemies_and_spells()

func run_through_enemies_and_spells() -> void:
	var names = Enemies.list() + PackedStringArray(Globals.SPELLS.values())
	const DESIRED_LENGTH = 6
	const DESIRED_VALUE = 8
	for name in names:
		if "_" not in name and len(name) == DESIRED_LENGTH and Letters.get_face_value(name) == DESIRED_VALUE:
			print(name)
	
	

func run_through_colors() -> void:
	var file = FileAccess.open("res://mods/proverbpalace/source/editor_scripts/colornames.csv", FileAccess.READ)

	const DESIRED_LENGTH = 8
	const DESIRED_VALUE = 12
	
	var headers = file.get_csv_line()
	

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()

		if row.is_empty() or (row.size() == 1 and row[0] == ""):
			break
		var color_name: String = row[0].to_lower()
		var valid = true
		for chr in illegal_characters:
			if chr in color_name:
				valid=false
				color_name = color_name.replace(chr,"")
		if len(color_name) != DESIRED_LENGTH or Letters.get_string_value(color_name) != DESIRED_VALUE:
			continue
		if !valid:
			continue
		
		print(color_name)
		
		
	#butterscotches
	#watermelonade

	file.close()
	
	var word_dictionary: WordDictionary = load("res://words/compiled.res")
	var color_words = word_dictionary.word_flags[WordDictionary.WordFlags.COLORS].words
	
	
	for word in color_words:
		if (len(word) == DESIRED_LENGTH) and (Letters.get_string_value(word) == DESIRED_VALUE):
			print(word)
