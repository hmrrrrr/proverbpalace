@tool
extends EditorScript

func _run() -> void:
	var board := generate_uniform_board()
	
const elim_rares = false

func shift_board(board:String,n := 1) -> String:
	var letters = Letters.ALPHABET.duplicate()
	if elim_rares:
		for l in letters.duplicate():
			if Letters.LETTERS[l] == 1.:
				letters.erase(l)
	for i in range(len(board)):
		var let = board[i]
		var index = letters.find(let)
		if index != -1:
			index = (index + n)%len(letters)
			board[i] = letters[index]
	return board

func generate_uniform_board() -> String:
	
	var letters = Letters.ALPHABET.duplicate()
	if elim_rares:
		for l in letters.duplicate():
			if Letters.LETTERS[l] == 1.:
				letters.erase(l)
	var board = [
		["","","",""],
		["","","",""],
		["","","",""],
		["","","",""],
	]
	
	randomize()
	for i in 4:
		for j in 4:
			board[i][j] = letters[randi()%len(letters)]
	
	var out_str = ""
	for line in board:
		out_str += "".join(line)+"\n"
	return out_str
