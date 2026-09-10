extends "res://source/autoload/mod_loader/mod_packer.gd"

var running_again = false

func _ready() -> void :
	var pack: = PackMeta.new()
	
	if running_again:
		ignored_files.append("BOOST_SPELL_WEIGHTS.yes")
	
	var mod_folder: = "res://mods/%s" % mod_id
	for file in FileUtil.get_file_paths_recursive(mod_folder):
		var file_name: = file.get_file()
		if file_name not in ignored_files and file_name.get_extension() not in ignored_extensions:
			pack.pack_file(file)

	var pack_extension: = "pck"
	if pack_zip:
		pack_extension = "zip"

	var cache_pack_path: String = ""
	if separate_cache_pack:
		cache_pack_path = "res://mods/%s/cache.%s" % [mod_id, pack_extension]

	var pack_path: = "res://mods/%s/%s.%s" % [mod_id, pack_name, pack_extension]
	if pack_zip:
		pack.pack_zip(pack_path, cache_pack_path)
	else:
		pack.pack_pck(pack_path, cache_pack_path)

	if create_distribution_zip:
		var zip_packer: = ZIPPacker.new()
		zip_packer.open("res://mods/%s/%s%s.zip" % [mod_id, mod_id,"_BOOSTED_WEIGHTS" if not running_again else ""])
		zip_packer.start_file("%s/mod.json" % mod_id)
		zip_packer.write_file(FileAccess.get_file_as_bytes("res://mods/%s/mod.json" % [mod_id]))
		zip_packer.close_file()

		zip_packer.start_file("%s/%s.%s" % [mod_id, pack_name, pack_extension])
		zip_packer.write_file(FileAccess.get_file_as_bytes(pack_path))
		zip_packer.close_file()

		if cache_pack_path != "":
			zip_packer.start_file("%s/cache.%s" % [mod_id, pack_extension])
			zip_packer.write_file(FileAccess.get_file_as_bytes(cache_pack_path))
			zip_packer.close_file()

		zip_packer.close()
	
	if !running_again:
		running_again = true
		_ready()
	
	get_tree().quit()
