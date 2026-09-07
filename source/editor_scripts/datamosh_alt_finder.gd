@tool
extends EditorScript

func compare_word_value(wordA, wordB):
	var valueA = 0
	var valueB = 0

	for letter in wordA:
		valueA += Letters.LETTER_VALUES[letter]

	for letter in wordB:
		valueB += Letters.LETTER_VALUES[letter]

	return valueA > valueB
	
func _run() -> void:
	
	var game_dictionary: WordDictionary = ResourceLoader.load("res://words/compiled.res", "", ResourceLoader.CACHE_MODE_IGNORE)
	var common_words := game_dictionary.words.words
	print(get_number_alts_for_word("up"))
	#for word in common_words:
		#var output = get_number_alts_for_word(word)
		#
		#if len(output) > 0:
			#print("%s => %s"%[word,output])
			

func get_number_alts_for_word(target_word: String) -> PackedStringArray:
	var game_dictionary: WordDictionary = ResourceLoader.load("res://words/compiled.res", "", ResourceLoader.CACHE_MODE_IGNORE)
	var target_word_nums = ""
	var common_words := game_dictionary.words.words
	for target_letter in target_word:
		for key in Letters.NUMPAD_CHARACTERS.keys():
			var options = Letters.NUMPAD_CHARACTERS[key]
			if target_letter in options:
				target_word_nums += key
				break
	var alts: PackedStringArray = []
	for word in common_words:
		var i = 0
		if len(word) != len(target_word):
			continue
		var should_skip = false
		for letter in word:
			for key in Letters.NUMPAD_CHARACTERS.keys():
				var options = Letters.NUMPAD_CHARACTERS[key]
				if letter in options:
					if target_word_nums[i] != key:
						should_skip = true
						break
					else:
						i += 1
			if should_skip:
				break
		if !should_skip and word != target_word:
			alts.append(word)
	#print("%s => %s"%[target_word,alts])
	return alts
	
