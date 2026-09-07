extends "res://source/tile_status/linked.gd"

const FUZZY = "fuzzy"
const ZIPTIE = "ziptie"

const FUZZY_LINK_BOTTOM = preload("res://mods/proverbpalace/arte/fuzzy_link1.png")
const FUZZY_LINK_TOP = preload("res://mods/proverbpalace/arte/fuzzy_link2.png")
const ZIPTIE_LINK_BOTTOM = preload("res://mods/proverbpalace/arte/ziptie_link1.png")
const ZIPTIE_LINK_TOP = preload("res://mods/proverbpalace/arte/ziptie_link2.png")
const DEFAULT_TILE_LINKED_TOP = preload("res://arte/tiles/tile_linked_top.png")
const DEFAULT_TILE_LINKED_BOTTOM = preload("res://arte/tiles/tile_linked_bottom.png")
const ZIPTIE_LINKED_MATERIAL = preload("res://mods/proverbpalace/arte/spells/ziptie_linked_material.tres")

func set_link_id(value):
	
	tile.tile_sprite.linked_bottom.hframes = 1
	tile.tile_sprite.linked_bottom.vframes = 1
	tile.tile_sprite.linked_top.hframes = 1
	tile.tile_sprite.linked_top.vframes = 1
	tile.tile_sprite.linked_top.visible = true
	tile.tile_sprite.linked_bottom.visible = true
	
	tile.tile_sprite.linked_bottom.material = null
	tile.tile_sprite.linked_top.material = null
	
	link_id = value
	if value == FUZZY:
		tile.tile_sprite.linked_top.texture = FUZZY_LINK_TOP
		tile.tile_sprite.linked_bottom.texture = FUZZY_LINK_BOTTOM
	elif value == ZIPTIE:
		tile.tile_sprite.linked_top.texture = ZIPTIE_LINK_TOP
		tile.tile_sprite.linked_bottom.texture = ZIPTIE_LINK_BOTTOM
		
		tile.tile_sprite.linked_bottom.material = ZIPTIE_LINKED_MATERIAL
		tile.tile_sprite.linked_top.material = ZIPTIE_LINKED_MATERIAL
	else:
		tile.tile_sprite.linked_bottom.hframes = 3
		tile.tile_sprite.linked_bottom.vframes = 2
		tile.tile_sprite.linked_top.hframes = 3
		tile.tile_sprite.linked_top.vframes = 2
		super(value)

func clear():
	super()
	tile.tile_sprite.linked_top.texture = DEFAULT_TILE_LINKED_TOP
	tile.tile_sprite.linked_bottom.texture = DEFAULT_TILE_LINKED_BOTTOM
	tile.tile_sprite.linked_bottom.hframes = 3
	tile.tile_sprite.linked_bottom.vframes = 2
