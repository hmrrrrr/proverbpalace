@tool
extends EditorScript

const MIRROR_CHARS_HORIZONTAL = [
	"bd","pq","oo","vv","ww","88"    #,"Ԑ3"
]
const MIRROR_CHARS_180 = [
	"69", "ss", "88", "oo", "bq", "dp", "mw"
]


func get_bigram_permutations(
	combo_a: String, combo_b: String, horizontal: bool
) -> Array[String]:
	var dict: Dictionary[String,bool] = {}
	
	for ind_a in range(2):
		for ind_b in range(2):
			var s = combo_a[ind_a] + combo_b[ind_b]
			dict[s] = true
			dict[s.reverse()] = true
				
	return dict.keys()


func _run() -> void:
	print(get_bigram_permutations(
		"pq","bd",false
	))
