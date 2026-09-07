extends "res://source/spells/letter_stamp.gd"
class_name PhotoAlbum

var faces_remaining: Array[String] = []

var pic_rotations: Array[float] = []
var pic_data: Array[Image] = []

var album_overlay: ToyCameraAlbumOverlay = null
const TOY_CAMERA_ALBUM_OVERLAY = preload("res://mods/proverbpalace/source/minigames/toy_camera_album_overlay.tscn")

var can_show_album := true

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if album_overlay:
			album_overlay.queue_free()
			
func on_hover():
	if album_overlay == null and can_show_album:
		album_overlay = ToyCamera.add_album_ui(pic_data,pic_rotations)
	
func on_unhover():
	if album_overlay:
		album_overlay.queue_free()
		album_overlay = null

func get_save_data():
	var save = super.get_save_data()
	save["faces_remaining"] = faces_remaining
	var byte_arrays = []
	for pic in pic_data:
		byte_arrays.append(pic.save_webp_to_buffer(true,.5))
	save["pic_data"] = byte_arrays
	save["pic_rotations"] = pic_rotations
	return save


func load_save_data(save):
	faces_remaining = save.faces_remaining
	pic_rotations = save.pic_rotations
	var byte_arrays = save.pic_data
	for byte_array in byte_arrays:
		var img = Image.new()
		img.load_webp_from_buffer(byte_array)
		pic_data.append(img)
	super.load_save_data(save)


func _spell_init():
	super._spell_init()
	do_randomization = false

func _use():
	can_show_album = false
	await super()
	can_show_album = true

func apply_to_tile(tile: Tile, real_tile: Tile, is_preview: bool, _is_preview_update: bool) -> void:
	super(tile,real_tile,is_preview,_is_preview_update)
	if !is_preview:
		var popped_face = faces_remaining.pop_back()
		if popped_face:
			face = popped_face
		else:
			charge = 0
	

func set_data(raw_faces: Array[String], photos: Array[Image], rotations: Array[float]):
	faces_remaining = raw_faces
	max_charge = len(raw_faces)
	charge = len(raw_faces)
	face = faces_remaining.pop_back()
	
	pic_data = photos
	pic_rotations = rotations
