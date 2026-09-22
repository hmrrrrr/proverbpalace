extends Spell
class_name ColorBelt

const STATS := [
	{len=3, val=4 ,color=Color("a4bf20"),name="pea"},
	{len=3, val=5 ,color=Color("87ceeb"),name="sky"},
	{len=4, val=6 ,color=Color("20a040"),name="jade"},
	{len=4, val=7 ,color=Color("0f0f0f"),name="onyx"},
	{len=5, val=7 ,color=Color("0071ff"),name="azure"},
	{len=5, val=8 ,color=Color("74724e"),name="hazel"},
	{len=6, val=8 ,color=Color("6f4e37"),name="coffee"},
	{len=6, val=9 ,color=Color("f7c15c"),name="papaya"},
	{len=7, val=9, color=Color("e600b0"),name="fuchsia"},
	{len=7, val=10,color=Color("722f37"),name="oxblood"},
	{len=7, val=11,color=Color("ff6b08"),name="pumpkin"},
	{len=8, val=11,color=Color("c04000"),name="mahogany"},
	{len=8, val=12,color=Color("dfd8c3"),name="bookworm"},
	{len=9, val=12,color=Color("b3346c"),name="raspberry"},
	{len=10,val=13,color=Color("70db93"),name="aquamarine"},
	{len=11,val=14,color=Color("9966cc"),name="amethystine"},
	{len=12,val=14,color=Color("cf8f3c"),name="butterscotch"},
	{len=13,val=15,color=Color("eb4652"),name="watermelonade",q=true},
]

var last_kills: int = Game.main.kills

var current_color: int = 0

func get_save_data():
	var s = super()
	s.exp = last_kills
	s.current_color = current_color
	return s
	
func load_save_data(save):
	super(save)
	current_color = save.current_color
	last_kills = save.exp

func _ready() -> void:
	Game.player.turn_started.connect(_turn_started)
	
func _turn_started():
	if Game.main.kills != last_kills:
		_battle_started()
		last_kills = Game.main.kills

func _battle_started():
	current_color = mini(current_color+1,len(STATS)-1)
	shake.emit()
	description_updated.emit()

var current_stats: Dictionary :
	get():
		return STATS[current_color]

func _first_spawn(is_transform: = false) -> void:
	super(is_transform)
	const MAX_UPGRADES := 11
	var max_starting_color = len(STATS) - (MAX_UPGRADES) # 4
	
	if Game.main.player.id == Globals.CHARACTERS.JUBILIST:
		max_starting_color = len(STATS) - 2
	
	#assertion
	#for stats in STATS:
		#if len(stats.name) != stats.len and Letters.get_string_value(stats.name) != stats.val:
			#print(stats)
	
	current_color = rng.spell.randi_range(0, max_starting_color )
	current_color = len(STATS) -1

func set_status_tooltips():
	status_tooltips = ["counter"]

func get_tooltip_context() -> Dictionary:
	return super().merged(
		{
			current_length =current_stats.len,
			current_value =current_stats.val,
			current_color = current_stats.name,
			quotes = current_stats.get('q'),
		}
	)

func _use():
	if not has_valid_word():
		_end_use()
		return

	Game.stop_turn_timers.emit()
	
	AudioManager.play_sound(Sounds.FREEZER.VOX_FOREIGN_BODY)
	for tile: Tile in word_builder.tiles:
		tile.add_status("counter")
		tile.animation.play("shake")
		AudioManager.play_sound(Sounds.GENERIC.APPLY_STATUS)
		await Game.timeout(0.02)
	
	word_builder.update()


	await Game.timeout(0.5)
	main.force_end_player_turn(true)

	_post_use()

func has_valid_word() -> bool:
	var words: WordList = word_builder.get_words()
	
	if not (word_builder.can_submit_tiles() and word_builder.can_submit_words(words) and words.sub_lists.size() == 1):
		return false
	
	var value_sum := 0
	
	for tile: Tile in word_builder.tiles:
		value_sum += tile.get_value()
	
	return value_sum == current_stats.val and len(word_builder.words_list.get_first_word()) == current_stats.len

func is_usable():
	return has_valid_word()
