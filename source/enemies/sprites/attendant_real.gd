@tool
extends Node2D

var segments = []
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var top_segment_x_offset := 0. :
	set(v):
		top_segment_x_offset = v
		update_segment_x_positions()

@export_range(-1,2,0.01) var segment_x_skew := 0.:
	set(v):
		segment_x_skew = v
		update_segment_x_positions()

@export var bottom_segment_x_offset := 0.:
	set(v):
		bottom_segment_x_offset = v
		update_segment_x_positions()

@export var x_animation_curve : Curve

func update_segment_x_positions() -> void:
	if x_animation_curve == null:
		return
	x_animation_curve.set_point_value(1,segment_x_skew)
	
	for i in len(segments):
		var t: float = remap(
			i,0,len(segments)-1,0,1
		)
		t = x_animation_curve.sample(t)
		var segment: Node2D = segments[i]
		var desired_x = remap(
			t,0,1,bottom_segment_x_offset,top_segment_x_offset
		)
		segment.position.x = desired_x
		
		
func _ready() -> void:
	segments = $Pivot.get_children()

@export var segment_rotation: float : 
	set(v):
		segment_rotation = v
		for segment in segments:
			segment.segment_rotation_offset = v


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play(
		"slide_left" if anim_name == "slide_right" else "slide_right"
	)
