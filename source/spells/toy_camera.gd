extends Spell
class_name ToyCamera
var pics_taken: PackedStringArray = []
var raw_faces: PackedStringArray = []

var pic_rotations: Array[float] = []
var pic_data: Array[Image] = []

var album_overlay: ToyCameraAlbumOverlay = null
const TOY_CAMERA_ALBUM_OVERLAY = preload("res://mods/proverbpalace/source/minigames/toy_camera_album_overlay.tscn")
const TOY_CAMERA_ALBUM_ENTRY = preload("res://mods/proverbpalace/source/minigames/toy_camera_album_entry.tscn")

const SOUNDS = {
	CAMERA = preload("res://mods/proverbpalace/sounds/camera.wav"),
	CAMERAPRINT = preload("res://mods/proverbpalace/sounds/cameraprint.wav")
}

const FLASH_FX = preload("res://mods/proverbpalace/source/spells/flash_fx.tscn")
const ARCING_PROJECTILE = preload("res://source/effects/arcing_projectile.tscn")

var can_show_album := true

func _ready() -> void:
	if OS.has_feature("debug") and false:
		for l in Letters.ALPHABET:
			if l != "e":
				pics_taken.append(l)
				raw_faces.append(l)

func get_save_data():
	var save = super.get_save_data()
	var byte_arrays: Array[PackedByteArray] = []
	for pic in pic_data:
		byte_arrays.append(pic.save_webp_to_buffer(true,.5))
		
	save["pics_taken"] = pics_taken # PackedStringArray of each individual letter
	save["pic_data"] = byte_arrays # Array[PackedByteArray] of .webp image buffers
	save["pic_rotations"] = pic_rotations # Array[float] of rotation data
	save["raw_faces"] = raw_faces # PackedStringArray of raw faces to use later >:)
	return save

func load_save_data(save):
	super.load_save_data(save)
	pics_taken = save.pics_taken
	raw_faces = save.raw_faces
	
	pic_rotations = save.pic_rotations
	var byte_arrays = save.pic_data
	for byte_array in byte_arrays:
		var img = Image.new()
		img.load_webp_from_buffer(byte_array)
		pic_data.append(img)
	description_updated.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if album_overlay:
			album_overlay.queue_free()

static func add_album_ui(pics: Array[Image],rotations: Array[float]) -> ToyCameraAlbumOverlay:
	var new_album_overlay = TOY_CAMERA_ALBUM_OVERLAY.instantiate()
	new_album_overlay.ready.connect(
		func():
			new_album_overlay.load_pics(pics,rotations)
	)
	Game.main.get_node("HUDLayer").add_child(new_album_overlay)

	return new_album_overlay
	

func on_hover():
	if album_overlay == null and can_show_album:
		album_overlay = add_album_ui(pic_data,pic_rotations)
	
func on_unhover():
	if album_overlay:
		album_overlay.queue_free()
		album_overlay = null
	
func handle_invalid_tile(tile):
	var would_be_valid: bool = (
		(tile.type == TileType.DEFENSE) or (tile.has_status(TileStatus.FROZEN))
	) and (
		!tile.has_any_effect(Globals.WILDCARD_EFFECTS + [TileEffect.SHIMMERING])
	)
	
	var breaking_letter := ""
	for letter in tile.face:
		if letter in pics_taken:
			breaking_letter = letter
			break
	
	if (would_be_valid and (breaking_letter != "")):
		var word_hint := word_builder.word_hint as WordHint
		(func ():
			await Game.timeout(.11)
			word_hint.temporary_warning("misc/word_warnings/already_in_album",{letter=breaking_letter})
		).call()

func create_flash_effect(tile: Tile) -> FlashFX:
	var flash := FLASH_FX.instantiate() as FlashFX
	
	main.add_child(flash)
	flash.global_position = tile.global_position
	return flash

func get_tooltip_context():
	var num_pics = len(pics_taken)
	return {
		num_letters = len(Letters.ALPHABET),
		photo_taken = num_pics > 0,
		photos_taken = num_pics
	}


func queue_save_pic(tile: Tile) -> void:
	await RenderingServer.frame_post_draw
	var viewport: Viewport = tile_board.get_viewport()
	var t_a = (tile.tile_sprite.get_global_transform_with_canvas())
	var t_b = (viewport.get_stretch_transform())
	
	var tra = (t_b*t_a)
	tra.origin = Vector2.ZERO
	const extents = 32.
	var rect = Rect2(tile.global_position-Vector2.ONE*extents/2.,Vector2.ONE*extents)
	var img = viewport.get_texture().get_image().get_region(rect*tra)
	pic_data.append(img)
	await create_flash_effect(tile).done
	word_builder.on_tile_cleared(tile,player.get_spells())
	tile_board.remove_tile(tile, {
		delete_tiles = true, 
		settle = true, 
		restock = true,
	})
	(func ():
		await Game.timeout(.3)
		
		AudioManager.play_sound(SOUNDS.CAMERAPRINT,randf_range(.95,1.05))
		
		var projectile := ARCING_PROJECTILE.instantiate() as ArcingProjectile
		main.projectile_container.add_child(projectile)
		var photo := TOY_CAMERA_ALBUM_ENTRY.instantiate() as ToyCameraAlbumEntry
		projectile.add_child(photo)
		photo.photo_texture.texture = ImageTexture.create_from_image(img)
		projectile.global_position = player_spell_slot.global_position + Vector2(92,48)/2.
		projectile.gravity = 534
		projectile.rotation = 0
		projectile.angular_velocity = randf_range(-1.5,1.5)
		projectile.angular_deceleration = 4.
		projectile.velocity = Vector2(0,-285)
		projectile.look_at_direction = false
		await Game.timeout(.55)
		projectile.gravity = 0
		projectile.velocity = Vector2.ZERO
		await Game.timeout(.45)
		Game.get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property(projectile,"modulate",Color(1,1,1,0),.4)
		await Game.timeout(1.)
		projectile.queue_free()
	).call()
func _use():
	can_show_album = false
	if album_overlay:
		album_overlay.queue_free()
		album_overlay = null
	var tile: = await get_selection()
	can_show_album = true
	if tile == null:
		_end_use()
		return

	AudioManager.play_sound(SOUNDS.CAMERA)

	var value := tile.get_value()
	if tile.has_status(TileStatus.CRIT):
		value = ceil(value*1.5)
	player.defense += value
	for letter in tile.face:
		pics_taken.append(letter)
		pic_rotations.append(randf_range(-6,6))
	raw_faces.append(tile.face)
	await queue_save_pic(tile)
	if len(pics_taken) == len(Letters.ALPHABET):
		transform_spell(
			"proverbpalace:photo_album",
			true, true, false,
			false, false,
			func(spell: Spell): (spell as PhotoAlbum).set_data(raw_faces,pic_data,pic_rotations)
		)
		_post_use(false, true)
	
	else:
		_post_use()


func is_tile_selectable(tile: Tile) -> bool:
	for letter in tile.face:
		if letter in pics_taken:
			return false
	return (
		(tile.type == TileType.DEFENSE) or (tile.has_status(TileStatus.FROZEN))
	) and (
		!tile.has_any_effect(Globals.WILDCARD_EFFECTS + [TileEffect.SHIMMERING])
	) and tile.has_face()
