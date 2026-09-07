@tool
extends Sprite2D
class_name SnakeSegment

signal death_finished

@onready var snake_face: Sprite2D = $SnakeFace
@onready var snake_connection_overlay: Sprite2D = $SnakeConnectionOverlay
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SNAKE_SEGMENT_CONNECTION_OVERLAY = preload("res://mods/proverbpalace/source/spells/snake_segment_connection_overlay.tscn")

@onready var parent := $".."

var parent_scale_affects_adopted_children := false

@export var parent_scale: Vector2 = Vector2(1,1) :
	set(v):
		if parent and !Engine.is_editor_hint():
			parent.scale = v
		elif Engine.is_editor_hint():
			scale = v
		
		if parent_scale_affects_adopted_children:
			for child in adopted_children:
				child.scale = v
	get():
		if parent and !Engine.is_editor_hint():
			return parent.scale
		elif Engine.is_editor_hint():
			return scale
		return Vector2.ONE
		

const CONNECTION_FRAMES = {
	Vector2i.DOWN: 1,
	Vector2i.LEFT: 2,
	Vector2i.UP: 3,
	Vector2i.RIGHT: 4,
}
const FACE_FRAMES = {
	Vector2i.DOWN: 5,
	Vector2i.LEFT: 6,
	Vector2i.UP: 7,
	Vector2i.RIGHT: 8,
}

var adopted_children: Array[Node] = []

func add_connection_overlay(direction: Vector2i, other_segment: SnakeSegment):
	var connection := SNAKE_SEGMENT_CONNECTION_OVERLAY.instantiate() as Sprite2D
	get_node("../..").add_child(connection)
	connection.material = material
	connection.self_modulate = Color(lerp(other_segment.self_modulate,self_modulate,.5),1.)
	adopted_children.append(connection)
	#connection.top_level = true
	connection.frame = CONNECTION_FRAMES[direction]

func _exit_tree():
	for node in adopted_children:
		node.queue_free()

func make_face_dead() -> void:
	snake_face.frame += 4

func die_animation() -> Signal:
	animation_player.play("die")
	parent_scale_affects_adopted_children = true
	return death_finished
	

func update_state(face_direction: Vector2i, first := false):
	snake_face.visible = face_direction != Vector2i.ZERO
	
	if snake_face.visible:
		snake_face.frame = FACE_FRAMES[face_direction]
