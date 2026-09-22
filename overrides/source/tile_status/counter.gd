extends Status

const MAX_PARTICLE_DELAY = 10
const MIN_PARTICLE_DELAY = 2
var particle_delay = randf_range(MIN_PARTICLE_DELAY, MAX_PARTICLE_DELAY)

const COUNTER_OVERLAY = preload("res://mods/proverbpalace/source/effects/counter_overlay.tscn")

const DEBOSS_COLOR = [
	"#e6adb6", "#e3a3c0"
]
const MASKS = [
	preload("res://mods/proverbpalace/arte/tiles/counter/tile_inside_mask1.png"),
	preload("res://mods/proverbpalace/arte/tiles/counter/tile_inside_mask2.png"),
]
func _tile_face_pre_draw() -> void:
	#tile.tile_face.set_color(
		#"#FFFFFF"
	#)
	#tile.tile_face.value_color = "#FFFFFF"
	tile.tile_face.set_deboss_color(
		DEBOSS_COLOR[int(tile.type)]
	)

var overlay: CounterOverlay

func _status_connect() -> void:
	
	if !tile.tile_sprite.has_node("CounterOverlay"):
		overlay = COUNTER_OVERLAY.instantiate()
		tile.tile_sprite.add_child(overlay)
		tile.tile_sprite.material_inheritors.append(overlay)
		tile.tile_sprite.move_child(overlay,tile.tile_sprite.hole_sprite.get_index()+1)
	update_frame()
	
	tile.tile_face.draw.connect(_tile_face_pre_draw)

func update_frame() -> void :
	tile.tile_sprite.base_sprite_anim_player.stop()
	var frame = Globals.TileStatusFrame.eternal
	tile.tile_sprite.set_frame(frame)
	overlay.texture = MASKS[tile.type]
func update():
	super()
func clear():
	super()
	var node = tile.tile_sprite.get_node_or_null("CounterOverlay")
	if node:
		tile.tile_sprite.material_inheritors.erase(node)
		node.name = "fuck"
		node.queue_free()
		node.hide()
