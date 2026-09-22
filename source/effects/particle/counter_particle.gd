@tool
extends Node2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const FRAME_COUNT = 5

@export_range(0,2) var variant := 0 : set=_set_variant
@export_range(0,FRAME_COUNT-1) var frame := 0 : set=_set_frame
@export var opacity_curve : Curve
@export var gradient: Gradient

const position_variation := 9

var progress := 0.

func update_frame():
	if sprite:
		sprite.frame = FRAME_COUNT*variant + frame
	

func _set_variant(val:int):
	variant = val
	update_frame()

func _set_frame(val:int):
	frame=val
	update_frame()


func _process(delta: float) -> void:
	modulate.a = opacity_curve.sample_baked(progress)
	progress += delta
	if progress > opacity_curve.max_domain:
		if !Engine.is_editor_hint():
			queue_free()
		else:
			progress = 0.

func _ready() -> void:
	opacity_curve.min_domain = 0
	animation_player.speed_scale = 1./opacity_curve.max_domain
	
	modulate = Color(gradient.sample(randf()),0.)
	if randi()%2==0:
		modulate=modulate.inverted()
	variant = randi_range(0,2)
	
	rotation_degrees = [0,90].pick_random()
	
	position.x += randi_range(-position_variation,position_variation)
	position.y += randi_range(-position_variation,position_variation)
