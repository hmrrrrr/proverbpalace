@tool
extends EditorScript

const CHARS = "AbcCdEFgHhIijJLnoOPqrStUuyZ234567789ソ=—フレГҀ¿¹ԇōīəΞγG″こ)\\^'ñλײַ"
const _7_SEG_ATLAS = preload("res://mods/proverbpalace/source/7seg/7seg.png")

const SEG_POSITIONS := [
	Vector2i(1,0),
	Vector2i(2,1),
	Vector2i(2,3),
	Vector2i(1,4),
	Vector2i(0,3),
	Vector2i(0,1),
	Vector2i(1,2),
]

func _run() -> void:
	var library := SevenSegmentLibrary.new()
	
	var image := _7_SEG_ATLAS.get_image()
	
	var get_segment := func (frame: int, position: int) -> bool:
		var coord: Vector2i = Vector2i(3*frame,0) + SEG_POSITIONS[position]
		return image.get_pixelv(coord).r > 0
	
	var get_segments := func (frame:int) -> Array[bool]:
		var output_arr := [false,false,false,false,false,false,false]
		for i in range(7): output_arr[i] = get_segment.call(frame,i)
		return output_arr
	
	var current_frame := 0
	for character in CHARS:
		var sev_seg_character := SevenSegCharacter.new()
		sev_seg_character.character = character.to_lower()
		var arr_out = get_segments.call(current_frame)
		sev_seg_character.segments = arr_out
		
		library.characters.append(sev_seg_character)
		
		current_frame += 1
	
	
	ResourceSaver.save(library,"res://mods/proverbpalace/source/7seg/library.res")
