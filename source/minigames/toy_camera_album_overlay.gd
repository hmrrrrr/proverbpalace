class_name ToyCameraAlbumOverlay
extends Control
const TOY_CAMERA_ALBUM_ENTRY = preload("res://mods/proverbpalace/source/minigames/toy_camera_album_entry.tscn")
@onready var flow_container: FlowContainer = $FlowContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass

func load_pics(arr: Array[Image], rots: Array[float]):
	for i in range(len(arr)):
		var pic := arr[i]
		var rot := rots[i]
		var texture := ImageTexture.create_from_image(pic)
		var entry := TOY_CAMERA_ALBUM_ENTRY.instantiate() as ToyCameraAlbumEntry
		
		entry.ready.connect(
			func():
				entry.photo_texture.texture = texture
				entry.photo_texture.rotation_degrees = rot
				
		)
		flow_container.add_child(entry)
	animation_player.play("appear")
