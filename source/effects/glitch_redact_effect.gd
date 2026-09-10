extends Node2D
class_name GlitchRedactEffect
const BLACK_SQUARE = preload("res://mods/proverbpalace/source/effects/black_square.png")


func make_random_rect() -> Rect2:
	var left: float = randf_range(-8,0)
	var right: float = randf_range(0,8)
	var top: float = randf_range(0,-8)
	var bottom: float = randf_range(0,8)
	
	return Rect2(left,top,right-left,bottom-top)

func _draw() -> void:
	for i in 6:
		draw_texture_rect(
			BLACK_SQUARE, make_random_rect(), true
		)


func _on_timer_timeout() -> void:
	queue_redraw()
