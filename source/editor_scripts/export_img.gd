@tool
extends EditorScript


func _run():
	make_rg_tex(Vector2i(512,512))
	pass

func export_image(path: String):
	var file := load(path) as Texture2D
	if file:
		file.get_image().save_png("res://mods/proverbpalace/source/editor_scripts/img_export/output.png")


func make_rg_tex(size: Vector2i):
	var img = Image.create(size.x,size.y,false,Image.FORMAT_RGF)
	
	for i in size.x:
		var i_per := inverse_lerp(0,size.x-1,i)
		for j in size.y:
			var j_per := inverse_lerp(0,size.y-1,j)
			
			img.set_pixel(
				i,j, Color(i_per,j_per,0)
			)
	img.save_png("res://mods/proverbpalace/source/editor_scripts/img_export/rg_tex.png")
