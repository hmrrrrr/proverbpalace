@tool
extends Node2D

signal draw_pass_2

@onready var base: Sprite2D = $Base
@onready var top: Sprite2D = $Top




@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var shading_modulate: Gradient

@export var face_atlas_h_frames := 5
@export var face_atlas_v_frames := 4

@export var spike_length := 5.
@export var spike_angle := PI/2.

@export var has_spikes := false :
	set(v):
		has_spikes = v
		_update_segment_rotation()
		
@export var vertex_offset_base := Vector2(0,-2)
@export var vertex_offset_top := Vector2(0,-2)

@export_range(0,2) var atlas_row := 0

@export var animated_segment_rotation: float :
	set(v):
		animated_segment_rotation = wrapf(v,0,TAU)
		_update_segment_rotation()

@export var segment_rotation_offset: float :
	set(v):
		segment_rotation_offset = wrapf(v,0,TAU)
		_update_segment_rotation()

var ratchets := 0

func _update_segment_rotation():
	if is_node_ready():
		segment_rotation = segment_rotation
		base.rotation = segment_rotation
		top.rotation = segment_rotation
		queue_redraw()

const RATCHET_ROTATION := TAU/6.
const ATTENDANT_FACES = preload("res://mods/proverbpalace/arte/enemies/attendant_faces.png")

var segment_rotation: float :
	get():
		if animate_backwards:
			return segment_rotation_offset - animated_segment_rotation - RATCHET_ROTATION*ratchets
		return segment_rotation_offset + animated_segment_rotation + RATCHET_ROTATION*ratchets

@onready var markers: Dictionary[String,Marker2D] = {
	b1 = $Base/PrimitivePoint1,
	b2 = $Base/PrimitivePoint2,
	b3 = $Base/PrimitivePoint3,
	b4 = $Base/PrimitivePoint4,
	b5 = $Base/PrimitivePoint5,
	b6 = $Base/PrimitivePoint6,
	t1 = $Top/PrimitivePoint1,
	t2 = $Top/PrimitivePoint2,
	t3 = $Top/PrimitivePoint3,
	t4 = $Top/PrimitivePoint4,
	t5 = $Top/PrimitivePoint5,
	t6 = $Top/PrimitivePoint6,
	
	s1 = $SpikePivot/PrimitivePoint1,
	s2 = $SpikePivot/PrimitivePoint2,
	s3 = $SpikePivot/PrimitivePoint3,
	s4 = $SpikePivot/PrimitivePoint4,
	s5 = $SpikePivot/PrimitivePoint5,
	s6 = $SpikePivot/PrimitivePoint6,
	
}

@export var animate_backwards := false

@export var line_width: float = 5 : 
	set(v):
		line_width = v
		queue_redraw()

func animate_cycle():
	if !(animation_player.is_playing()):
		ratchet()
		animation_player.play("cycle")

func _draw() -> void:
	if !is_node_ready():
		return
		
	var indices: Array = range(1,7)
	
	var x_sorted = indices.duplicate()
	
	var axis_sort = func(index_a: int,index_b: int, axis: int):
			
			var next_a := wrapi(index_a+1,1,7)
			var next_b := wrapi(index_b+1,1,7)
			
			var top_point_a := (markers["t%d"%index_a].global_position)
			var top_point_b := (markers["t%d"%index_b].global_position)
			
			var next_top_point_a := (markers["t%d"%next_a].global_position)
			var next_top_point_b := (markers["t%d"%next_b].global_position)
			
			var avg_a = top_point_a.lerp(next_top_point_a,.5)
			var avg_b = top_point_b.lerp(next_top_point_b,.5)
			
			if avg_a[axis] > avg_b[axis]:
				return true
			return false
	
	indices.sort_custom(
		axis_sort.bind(1)
	)
	x_sorted.sort_custom(
		axis_sort.bind(0)
	)
	
	indices = indices.slice(0,3)
	
	indices.reverse()
	
	var polylines: Array[PackedVector2Array] = [] 
	
	for i: int in indices:
		var bottom_point := to_local(markers["b%d"%i].global_position+vertex_offset_base)
		var top_point := to_local(markers["t%d"%i].global_position+vertex_offset_top)
		
		var next_i := wrapi(i+1,1,7)
		
		var next_bottom_point := to_local(markers["b%d"%next_i].global_position+vertex_offset_base)
		var next_top_point := to_local(markers["t%d"%next_i].global_position+vertex_offset_top)
		var this_index = x_sorted.find(i)
		
		var spike_point = to_local(markers["s%d"%next_i].global_position)
		var spike_normal = (scale*markers["s%d"%next_i].position).normalized()
		
		var t_shading := remap(this_index,1,6,0,1)
		
		var frame_in_row := (i-1)
		
		var cel_size := Vector2(1,1)/Vector2(
			face_atlas_h_frames,
			face_atlas_v_frames
		)
		
		var frame_topleft = cel_size*Vector2(
			frame_in_row, atlas_row
		)
		
		var points := PackedVector2Array([
				top_point,next_top_point,
				next_bottom_point,bottom_point
			])
		
		draw_polygon(
			points,PackedColorArray([
				shading_modulate.sample(t_shading)
			]),
			PackedVector2Array([
				frame_topleft+Vector2(1,0)*cel_size,frame_topleft,
				frame_topleft+Vector2(0,1)*cel_size,frame_topleft+Vector2(1,1)*cel_size,
			]),
			ATTENDANT_FACES if !has_spikes else null
			#PackedColorArray([Color(t_overall,0,1)]),
		)
		
		var spike_points = PackedVector2Array([
			spike_point - spike_normal.rotated(-spike_angle)*spike_length,
			spike_point,
			spike_point - spike_normal.rotated(spike_angle)*spike_length,
		])
		
		draw_pass_2.connect(
			func():
				pass,
			Object.ConnectFlags.CONNECT_ONE_SHOT
		)
		
		
		points.append(top_point)
		polylines.append(points)
	
	for polyline in polylines:
		draw_polyline(
			polyline,Color.BLACK,line_width,true
		)
	draw_pass_2.emit()
	
	

func ratchet():
	ratchets += 1
	ratchets = ratchets % 6
	_update_segment_rotation()
