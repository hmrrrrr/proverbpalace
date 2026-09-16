extends "res://source/library/word_utility.gd"



func resolve_tile_words(tiles, priority_words: = PackedStringArray(), depriority_words: = PackedStringArray(), priority_flag: WordDictionary.WordFlags = WordDictionary.WordFlags.NONE) -> WordList:
	var full_word_list = WordList.new()
	full_word_list.all_valid = true

	var tile_sets = [[]]
	
	var mutagen_clusters = []
	var last_tile_was_mutagen = false
	var mutagen_clusters_by_tile = {}
	var cluster_index = -1
	var cluster_indices_hit = 0
	
	for tile: Tile in tiles:
		if tile.has_status("mutagen"):
			if !last_tile_was_mutagen:
				mutagen_clusters.append([])
				cluster_index += 1
			mutagen_clusters[-1].append(tile)
			mutagen_clusters_by_tile[tile] = cluster_index
			last_tile_was_mutagen = true
		else:
			last_tile_was_mutagen = false
	for tile: Tile in tiles:
		if tile.is_space():
			tile_sets.append([])
			continue
		if tile.has_status("mutagen"):
			var cluster_i = mutagen_clusters_by_tile[tile]
			if cluster_i == cluster_indices_hit:
				var cluster = mutagen_clusters[cluster_i]
				tile_sets[-1].append_array(cluster)
				tile_sets.append([])
				tile_sets[-1].append_array(cluster)
				cluster_indices_hit += 1
			continue

		var current_set = tile_sets[-1]
		current_set.append(tile)

	for tile_set in tile_sets:
		var word_list = WordList.new()
		word_list.set_priority(priority_words, depriority_words, priority_flag)
		
		var skip := false
		for tile: Tile in tile_set:
			word_list.add_tile(tile)
			if tile.face == ProverbPalaceTileManager.EPSILON:
				skip = true
				break
		if not tile_set.is_empty():
			if !skip:
				word_list.generate_permutations()
			word_list.resolve()

			if !skip:
				if word_list.all_valid:
					word_list.set_tile_wildcard_faces()

		full_word_list.extend_from_word_list(word_list)

	return full_word_list
