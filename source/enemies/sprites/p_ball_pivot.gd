@tool
extends Node2D

@export var center_position := Vector2(16,16)

@export var pivot_r := 6.
@export var pivot_t: float :
	set(t):
		pivot_t = t
		position = center_position + pivot_r*Vector2.from_angle(
			pivot_t
		)
