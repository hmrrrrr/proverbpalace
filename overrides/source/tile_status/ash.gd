extends Status

var kitty := false

var overlay: Sprite2D = null

const KITTY_OVERLAY = preload("res://mods/proverbpalace/source/effects/kitty_overlay.tscn")

func get_save_data():
	return {kitty=kitty}

func get_tooltip_context():
	return {status_value = get_status_value(), is_kitty = kitty}
	
func load_save_data(data):
	if data and "kitty" in data:
		kitty = data.kitty
	update_kittyous()

func update_kittyous() -> void:
	if kitty:
		if overlay == null:
			overlay = KITTY_OVERLAY.instantiate() as Sprite2D
			overlay.should_be_evil = false
			tile.tile_sprite.add_child(overlay)

func apply(args={}):
	if args.has("kitty"):
		kitty = args.kitty
	update_kittyous()
	
func clear():
	if overlay:
		overlay.queue_free()
		overlay.hide()
