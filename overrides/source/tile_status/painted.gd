extends Status
class_name PaintedStatus


enum Colors {
	RED,
	YELLOW,
	GREEN,
	CYAN,
	BLUE,
	MAGENTA,
	MAX
}

const EXCLUSIVE_STATUSES = [
	TileStatus.CAPITAL,
	TileStatus.PERIOD,
]

const COLOR_GRADIENT = preload("res://mods/proverbpalace/arte/effects/painted_gradient.tres")

var color: Colors

func get_color() -> Color:
	return COLOR_GRADIENT.sample(
		float(color)/6.
	)

func apply(color:Colors=Colors.RED):
	#for exclusive_status in EXCLUSIVE_STATUSES:
		#if tile.has_status(exclusive_status):
			#tile.remove_status(exclusive_status)
	self.color=color


func invalidates_word():
	if not tile.in_word() or tile.has_faceless_status():
		return false

	return Game.word_builder.get_tile_index_in_word(tile, true) != 0
