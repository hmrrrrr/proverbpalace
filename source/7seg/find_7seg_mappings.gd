@tool
extends EditorScript

var library: SevenSegmentLibrary = preload("res://mods/proverbpalace/source/7seg/library.res")

func _run() -> void:
	print_char_mappings(2,true,true)
	
	

func print_char_mappings(moves: int, ignore_non_latin := false, allow_wilds := true):
	
	var handled_chars = {}
	for char in library.characters:
		if not handled_chars.get(char.character):
			var mappings = get_mappings(char,moves,ignore_non_latin,allow_wilds)
			print("%s → [%s] (%d)"%[
				char.character,
				", ".join(mappings),
				len(mappings),
			])
			handled_chars[char.character] = true

func count_bits(num: int) -> int:
	var n = 0
	for i in range(8):
		n += ((num >> i) & 1)
	return n
	
func get_mappings(character: SevenSegCharacter, moves: int, ignore_non_latin := false, allow_wilds := true):
	var valid_chars: Dictionary = {}
	
	const pre_map_numbers := true
	
	for compare_character in library.characters:
		var the_character := compare_character.character
		if ((!ignore_non_latin or (the_character in Letters.ALPHABET) or (allow_wilds and the_character in Letters.NUMBERS))):
			var bit_diff := character.get_bits() ^ compare_character.get_bits()
			var required_turns := (count_bits(bit_diff))
			#print("%d, %d"%[bit_diff,count_bits(bit_diff)])
					
			if required_turns <= moves:
				if the_character in Letters.NUMBERS and pre_map_numbers:
					for c in Letters.NUMPAD_CHARACTERS[the_character]:
						valid_chars[c] = true
				else:
					valid_chars[compare_character.character] = true
	
	return valid_chars.keys()

	#if allowed_removals == 1:
		#var valid_chars: Dictionary
		#for i in range(7):
			#var segs_copy := character.segments.duplicate()
			#segs_copy[i] = false
			#var best_match := library.find_best_fit_character(segs_copy,allow_wilds)
			#if !(best_match == "" or best_match == character.character) and (!ignore_non_latin or (best_match in Letters.ALPHABET)):
				#valid_chars[best_match] = true
		#return valid_chars.keys()
		##print("%s => %s (%d removals)"%[character.character, ", ".join(valid_chars.keys()), original_removals])
	#else:
		#var valid_chars = {}
		#for i in range(7):
			#var dupe_char := character.duplicate_deep()
			#dupe_char.segments[i] = false
			#for char in get_mappings(dupe_char,allowed_removals-1):
				#valid_chars[char] = true
		#return valid_chars.keys()
