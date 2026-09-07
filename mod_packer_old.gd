@tool
extends EditorScript


var files: Array[String] = [
	"res://source/tile_status/mutagen.gd",
	"res://source/shaders/tile_sprite.gdshader",
	
	
	"res://mods/proverbpalace/overrides/word_utility.gd",
	
	"res://mods/proverbpalace/sprites/mutagen_wood_tile.png",
	"res://mods/proverbpalace/sprites/mutagen_plastic_tile.png",
	
	"res://mods/proverbpalace/intents/mutagen_intent.png",
	
	"res://mods/proverbpalace/bubble/mutagen_bubbles.gdshader",
	"res://mods/proverbpalace/bubble/mutagen_bubble.gd",
	"res://mods/proverbpalace/bubble/mutagen_bubbles.gd",
	"res://mods/proverbpalace/bubble/mutagen_bubble.tscn",
	"res://mods/proverbpalace/bubble/mutagen_bubbles.tscn",
	"res://mods/proverbpalace/bubble/bubbles_material.tres",
	"res://mods/proverbpalace/bubble/mutagen_bubble_mask.png",
	
	"res://source/enemies/dimorph.tscn",
	"res://source/enemies/dimorph.gd",
	"res://source/enemies/sprites/dimorph_sprite.tscn",
	
	"res://strings/status/mutagen.txt",
	"res://strings/enemy/dimorph.txt"
]


func _run() -> void :
	var packer: = PCKPacker.new()
	packer.pck_start("pack.pck")
	for file in files:
		if ResourceLoader.exists(file):
			var loaded: Resource = ResourceLoader.load(file)
			if loaded is CompressedTexture2D:
				packer.add_file(loaded.load_path, loaded.load_path)
				packer.add_file(file + ".import", file + ".import")
			else:
				packer.add_file(file, file)
		else:
			packer.add_file(file, file)

	packer.flush()
