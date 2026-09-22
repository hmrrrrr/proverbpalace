extends TileModifierSpell

var current_number := 2
var face :
	get():
		return str(current_number)

func load_save_data(save):
	super(save)
	
	current_number = save.current_number

func get_save_data():
	var s = super()
	s.current_number = current_number
	return s

func set_status_tooltips():
	status_tooltips = ["counter"]

func get_next_number() -> int:
	return wrapi(current_number + 1, 2, 10)

func get_tooltip_context():
	return super().merged(
		{letters = Letters.NUMPAD_CHARACTERS[face],face=face}
	)

func apply_to_tile(tile: Tile, _real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void :
	tile.set_face(face)
	tile.add_status("counter")
	if not is_preview:
		(tile.animation).play("pressed",-1,1.)
		#tile.add_poofcloud(Color("#e18d99"),null,false)
		AudioManager.play_sound(
			Sounds.SPELLS.SWITCH,
			remap(
				current_number,2,9,1.2,1.8
			)
		)
		current_number = get_next_number()
		description_updated.emit()

func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable() and 
		!tile.has_harmful_status() and !tile.has_status("counter")
	)
