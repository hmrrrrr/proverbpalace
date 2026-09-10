extends Line2D
class_name Streamer
@export_enum("PURPLE","YELLOW") var streamer_color: String = "PURPLE"

var bound_projectile: ArcingProjectile
var offset := Vector2.ZERO
const TEXTURES = {
	PURPLE = preload("res://mods/proverbpalace/source/effects/streamer_purple.png"),
	YELLOW = preload("res://mods/proverbpalace/source/effects/streamer_yellow.png")
}

const ANIMATE_BY := 3
var frame := 0
func _physics_process(_delta: float) -> void:
	if frame == 0:
		add_point(to_local(bound_projectile.position) + offset)
		if len(points) > 5:
			remove_point(0)
	frame = (frame+1)%ANIMATE_BY

func _ready() -> void:
	bound_projectile.tree_exiting.connect(queue_free)
	texture = TEXTURES[streamer_color]
