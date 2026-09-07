extends "res://source/tile_status/hole.gd"

const RECTANGLE_VARIANT_HACKY_CONSTANT = Vector2(1234,5678)

var is_rectangle_variant := false

const DEFAULT_HOLE_MASK = preload("res://arte/tiles/hole_mask.png")
const ALT_HOLE_MASK = preload("res://mods/proverbpalace/arte/tiles/alt_hole3.png")

const DEFAULT_HOLE_OUTLINE = preload("res://arte/tiles/hole_outline.png")
const ALT_HOLE_OUTLINE = preload("res://mods/proverbpalace/arte/tiles/alt_hole2.png")

const PLASTIC_ALT_HOLES = preload("res://mods/proverbpalace/arte/tiles/plastic_alt_holes.png")
const WOOD_ALT_HOLES = preload("res://mods/proverbpalace/arte/tiles/wood_alt_holes.png")


func apply_hole_variant() -> void:
	print("applying hole variant")
	tile.tile_sprite.material = tile.tile_sprite.material.duplicate()
	
	tile.tile_sprite.material.set_shader_parameter("hole_mask", ALT_HOLE_MASK)
	tile.tile_sprite.hole_outline.texture = ALT_HOLE_OUTLINE
	tile.tile_sprite.hole_sprite.texture = ALT_HOLE_OUTLINE
	
	tile.tile_sprite.hole_sprite.texture = WOOD_ALT_HOLES if tile.type == TileType.DAMAGE else PLASTIC_ALT_HOLES
	
	tile.tile_sprite.hole_sprite.texture_changed.connect(_on_hole_texture_changed)
	
	var hole_global_position = tile.tile_sprite.hole_sprite.global_position - Vector2(5.0, 4.0)
	tile.tile_sprite.set_instance_shader_parameter("hole_local_position", hole_global_position - tile.tile_sprite.global_position)
	for inheritor in tile.tile_sprite.material_inheritors:
		inheritor.set_instance_shader_parameter("hole_enabled", true)
		inheritor.set_instance_shader_parameter("hole_local_position", hole_global_position - inheritor.global_position)


func remove_hole_variant() -> void:
	print("removing hole variant")
	tile.tile_sprite.material.set_shader_parameter("hole_mask", DEFAULT_HOLE_MASK)
	tile.tile_sprite.hole_outline.texture = DEFAULT_HOLE_OUTLINE
	
	var hole_global_position = tile.tile_sprite.hole_sprite.global_position - Vector2(4.0, 4.0)
	tile.tile_sprite.set_instance_shader_parameter("hole_local_position", hole_global_position - tile.tile_sprite.global_position)
	for inheritor in tile.tile_sprite.material_inheritors:
		inheritor.set_instance_shader_parameter("hole_enabled", true)
		inheritor.set_instance_shader_parameter("hole_local_position", hole_global_position - inheritor.global_position)



func apply(position: Vector2 = RECTANGLE_VARIANT_HACKY_CONSTANT):
	if position.is_equal_approx(RECTANGLE_VARIANT_HACKY_CONSTANT):
		super(Vector2.ZERO)
		apply_hole_variant()
		is_rectangle_variant = true
	else:
		super(position)
		remove_hole_variant()
		is_rectangle_variant = false


func _on_hole_texture_changed():
	if is_rectangle_variant:
		tile.tile_sprite.hole_sprite.texture = WOOD_ALT_HOLES if tile.type == TileType.DAMAGE else PLASTIC_ALT_HOLES

	
func clear():
	remove_hole_variant()

func update_frame() -> void:
	super()

func get_save_data() -> Vector2:
	if is_rectangle_variant:
		return RECTANGLE_VARIANT_HACKY_CONSTANT
	return super()

func load_save_data(position: Variant):
	super(position)
	if (position is Vector2):
		if position.is_equal_approx(RECTANGLE_VARIANT_HACKY_CONSTANT):
			hole_position = Vector2(0,0)
			is_rectangle_variant = true
			tile.tile_sprite.set_hole(true, hole_position)
			apply_hole_variant()
