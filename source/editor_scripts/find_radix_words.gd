@tool
extends EditorScript
var game_dictionary: WordDictionary

func _run() -> void:
	game_dictionary = ResourceLoader.load("res://words/compiled.res", "", ResourceLoader.CACHE_MODE_IGNORE)
	var common_words := game_dictionary.word_flags[
		WordDictionary.WordFlags.COMMON
	].words
	var swear_words := game_dictionary.word_flags[
		WordDictionary.WordFlags.SWEAR
	].words
	var slurs := game_dictionary.word_flags[
		WordDictionary.WordFlags.SLUR
	].words
	
	var blacklist := swear_words + slurs
	#
	#for i in range(1,17):
		#print(
			#"radix %d: %s\n"%[i,find_radix_words(i).slice(0,10)]
			#)
	var words = find_radix_words(6)
	print_length_stats(words)
	print(words.filter(
		func(w): return w not in blacklist
	))
	
	

func print_length_stats(words: Array[String]):
	var stats := {}
	
	for word in words:
		var l := len(word)
		if l not in stats:
			stats[l] = 1
		else:
			stats[l] += 1
	
	print(stats)

func find_radix_words(radix: int) -> Array[String]:
	var words := game_dictionary.words.words
	
	var allowed_letters = Letters.ALPHABET.slice(0,radix)
	
	var found_words: Array[String] = []
	
	const COMMON_LETTERS := "lotnraise"
	
	for word in words:
		var validity := 2
		if len(word) <= 7:
			validity = 1
		for let in word:
			if let not in allowed_letters:
				if let in COMMON_LETTERS:
					validity -= 1
				else:
					validity -= 99
					break
		if validity >= 0:
			found_words.append(word)
	
	found_words.sort_custom(func(a,b): return len(a) > len(b))
	
	return found_words
			
