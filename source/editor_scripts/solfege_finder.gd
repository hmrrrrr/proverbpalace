@tool
extends EditorScript

const SOLFEGE = [
	"do","re","mi","fa","so","la","ti"
]

func _run() -> void:
	var word_dictionary: WordDictionary = load("res://words/compiled.res")
	
	var words = word_dictionary.words.words
	
	var word_solfege_counts: Dictionary = {}
	
	for word: String in words:
		var c := 0
		for i in range(len(word)-1):
			var bigram := word.substr(i,2)
			if bigram in SOLFEGE:
				c += 1
		word_solfege_counts[word] = c
	
	var best_words = word_solfege_counts.keys()
	best_words = best_words.filter(
		func(w): return word_solfege_counts[w] >= 4
	)
	best_words.sort_custom(
		func(a,b): return len(a) < len(b)
	)
	
	print(len(best_words))
