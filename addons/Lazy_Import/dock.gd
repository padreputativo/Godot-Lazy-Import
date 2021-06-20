tool
extends Node


# modified by the plugin
var _debug = false
var _plugin_ready = false
var _plugin

# before scan
var directory
var dir_found = false
var search_filter = "."

# after scan
var image_found = false
var image_extensions = ["jpg", "png", "jpeg", "tga", "bmp", "hdr", "psd", "svg", "svgz", "webp", "dds", "exr"]
var mesh_found = false
var mesh_extensions = ["fbx", "gltf", "glb", "dae", "obj"]
var image_checked = false
var mesh_checked = false

onready var boton_error = get_node("Buttons/Error")
onready var boton_toggle = get_node("Buttons/ToogleAll")
var toggleAll = true
onready var boton_scenes = get_node("Buttons/Scenes")
onready var material_filename = get_node("MaterialName")
onready var material_options = get_node("Buttons/MaterialOptions")
onready var boton_material = get_node("Buttons/Material")
onready var boton_test = get_node("Buttons/Test")
onready var file_list = get_node("ScrollContainer/File List")

const ImageConfig = preload("res://addons/Lazy_Import/templates/ImageConfig.tscn")
const MeshConfig = preload("res://addons/Lazy_Import/templates/MeshConfig.tscn")

func _ready():
	debug("_ready()")
	self.set_name("Lazy Import")
	debug("_ready: " + self.get_path())
	debug("_ready: " + self.name + " Dock loaded")
	# no hacer refresh aqui porque este archivo se carga aun no estando el plugin activado o cargado todavia

func kill():
	debug("kill()")
	self.queue_free()

func dock_isReady():
	if _plugin_ready && self is Node && self.name == "Lazy Import":
		return true
	else:
		push_error("Lazy Import Dock is not behaving properly! Try to restart Godot!")

func plugin_isReady():
	if _plugin is EditorPlugin && _plugin.name == "Lazy Import Plugin" && _plugin.has_method("is_enabled") && _plugin.is_enabled():
		return true
	else:
		push_error("Lazy Import Plugin is not behaving properly! Try to restart Godot!")

func debug(txt):
	if _debug: print("Lazy Import : " + txt)

func notify(txt):
	print("Lazy Import : " + txt)

func refresh():
	debug("refresh()")
	if dock_isReady():
		
		if plugin_isReady():
			
			debug("refresh: " + _plugin.get_path())
			
			# reset de variables
			directory = ""
			image_found = false
			mesh_found = false
			dir_found = false
			toggleAll = true
			
			# reset de hijos
			for n in file_list.get_children():
				file_list.remove_child(n)
			
			# esperamos un frame para que el dato reciba la señal de actualizarse
			yield(get_tree(), "idle_frame")
			
			# miramos que directorio hemos recibido
			directory = _plugin.selected_path()

			# revisamos el directorio
			var dir = Directory.new()
			if dir.dir_exists(directory) && dir.open(directory) == OK:
				debug("refresh: directory exists: " + directory)
				dir.open(directory)
				dir.list_dir_begin()

				var file = dir.get_next()
				while file != "":
					if not dir.current_is_dir() && file != "" && not file.begins_with(".") && search_filter in file.to_lower():
						if is_valid_image_extension(file):
							image_found = true
							debug("refresh: dir list: " + file)
							# instanciamos checkbox
							var node = ImageConfig.instance()
							node.get_node("CheckBox").text = file
							node.get_node("CheckBox").pressed = false
							node.get_node("CheckBox").connect("pressed", self, "refresh_buttons")
							node.get_node("OptionButton").selected = guess_layer(file)
							file_list.add_child(node)
						
						if is_valid_mesh_extension(file): 
							mesh_found = true
							debug("refresh: list: " + file)
							# instanciamos checkbox
							var node = MeshConfig.instance()
							node.get_node("CheckBox").text = file
							node.get_node("CheckBox").pressed = false
							node.get_node("CheckBox").connect("pressed", self, "refresh_buttons")
							
							if dir.file_exists(file + ".tscn"):
								node.get_node("CheckBox").disabled = true
								node.get_node("ToolButton").visible = true
							file_list.add_child(node)
							
					file = dir.get_next()
				dir.list_dir_end()
				
				dir_found = true
		
		refresh_buttons()

func is_valid_image_extension(file_name):
	assert(file_name)
	file_name = file_name.to_lower()
	for f in image_extensions:
		if file_name.ends_with("." + f):
			return true
	return false
	
func is_valid_mesh_extension(file_name):
	assert(file_name)
	file_name = file_name.to_lower()
	for f in mesh_extensions:
		if file_name.ends_with("." + f):
			return true
	return false

func refresh_buttons():
	debug("refresh_buttons()")
	if dock_isReady():
		
		boton_error.visible = false
		boton_toggle.visible = false
		boton_scenes.visible = false
		material_options.visible = false
		boton_material.visible = false
		material_filename.visible = false
		boton_test.visible = false
		
		if dir_found:
			if image_found || mesh_found:
				if toggleAll:
					boton_toggle.text = "All"
				else:
					boton_toggle.text = "Nothing"
				boton_toggle.visible = true
			else:
				boton_toggle.visible = false
				boton_error.text = "Nothing found in this Folder"
				boton_error.visible = true
				
			# check if files are checked
			image_checked = false
			mesh_checked = false
			for node in file_list.get_children():
				var N = node.get_node("CheckBox")
				if N is CheckBox && N.pressed == true:
					if is_valid_image_extension(N.text): image_checked = true
					if is_valid_mesh_extension(N.text): mesh_checked = true
			
			if image_checked && mesh_checked:
				boton_error.text = "Select Images OR Meshes"
				boton_error.visible = true
			elif image_checked:
				material_options.visible = true
				boton_material.visible = true
				material_filename.visible = true
				boton_test.visible = true
			elif mesh_checked:
				boton_scenes.visible = true
			else:
				boton_scenes.visible = false
				material_options.visible = false
				boton_material.visible = false
		else:
			boton_error.text = "Select Folder in FileSystem"
			boton_error.visible = true


func load_template(file):
	debug("load_template()")
	assert(file)
	
	var text = ""
	var f = File.new()
	f.open(file, File.READ)

	while not f.eof_reached():
		text += f.get_line()
	f.close()
	
	debug("load_template(): " + text)
	
	return text

func save_template(file_name, file_content):
	debug("load_template()")
	assert(file_name)
	assert(file_content)
	
	var file := File.new()
	file.open(file_name, file.WRITE)
	assert(file.is_open())
	file.store_string(file_content)
	file.close()
	
	notify("Lazy Import created a new file: " + file_name)

func remove_file_extensions(file):
	for f in image_extensions:
		if file.to_lower().ends_with("." + f):
			file = file.erase(f.length(), 1)
	for f in mesh_extensions:
		if file.to_lower().ends_with("." + f):
			file = file.erase(f.length(), 1)
	return file


func guess_layer(file_name):
	assert(file_name)
	var layer = 0
	
	# Ambiguous and super reduced  names
	for f in ["color"]:
		if (f in file_name.to_lower()): layer = 1
	for f in ["thickness"]: # thickness es otra forma de llamar al roughness?
		if (f in file_name.to_lower()): layer = 3
	for f in ["_n.", "_n_", "_nm_", "_nm."]: # normal map
		if (f in file_name.to_lower()): layer = 5
	for f in ["_ao_", "_ao."]: # ambient occlusion
		if (f in file_name.to_lower()): layer = 9
	for f in ["height"]: # ¿height seria lo contrario a depth?
		if (f in file_name.to_lower()): layer = 10
	for f in ["_ss_", "_ss."]: # subsurface scattering
		if (f in file_name.to_lower()): layer = 11
	for f in ["moads", "maods"]: # Multi Object Attribute-Driven Shading ¿decals?
		if (f in file_name.to_lower()): layer = 15
	
	# inverted layers = need reimport 
	for f in ["displacement"]: 
		if (f in file_name.to_lower()): layer = 10
	
	# nombres concretos y facilmente reconocibles
	for f in ["albedo"]:
		if (f in file_name.to_lower()): layer = 1
	for f in ["metallic"]:
		if (f in file_name.to_lower()): layer = 2
	for f in ["roughness"]:
		if (f in file_name.to_lower()): layer = 3
	for f in ["emission"]:
		if (f in file_name.to_lower()): layer = 4
	for f in ["normal", "normal map"]:
		if (f in file_name.to_lower()): layer = 5
	for f in ["rim"]:
		if (f in file_name.to_lower()): layer = 6
	for f in ["clearcoat"]:
		if (f in file_name.to_lower()): layer = 7
	for f in ["anisotropy"]:
		if (f in file_name.to_lower()): layer = 8
	for f in ["ambient occlusion", "occlusion"]:
		if (f in file_name.to_lower()): layer = 9
	for f in ["depth"]:
		if (f in file_name.to_lower()): layer = 10
	for f in ["scattering", "subsurface", "_ss_", "_ss."]:
		if (f in file_name.to_lower()): layer = 11
	for f in ["transmission"]:
		if (f in file_name.to_lower()): layer = 12
	for f in ["refraction"]:
		if (f in file_name.to_lower()): layer = 13
	for f in ["detail", "maskmap", "mask"]:
		if (f in file_name.to_lower()): layer = 14
	for f in ["decal"]:
		if (f in file_name.to_lower()): layer = 15
	for f in ["specular", "diffuse", "opacity"]:
		if (f in file_name.to_lower()): layer = 16

	return layer


func try_to_fix_file(file_name):
	debug("try_to_fix_file()")
	assert(file_name)

	for f in ["displacement"]:
		if (f in file_name.to_lower()):
			change_import_file(directory + file_name, "process/invert_color=false", "process/invert_color=true")
			
	for f in ["specular", "diffuse"]:
		if (f in file_name.to_lower()):
			notify("You need to convert the " + f + " map to PBR")
			
	for f in ["opacity", "glass"]:
		if (f in file_name.to_lower()):
			notify("You probably need to put the " + f + " map inside the Albedo Alpha channel")

func change_import_file(file_name, what, forwhat):
	debug("change_import_file()")
	assert(file_name)
	assert(what)
	assert(forwhat)
	
	var file_content = load_template(file_name + ".import")
	file_content.replace(what, forwhat)
	
	save_template(file_name, file_content)


func create_material(test):
	debug("_on_Materials_pressed()")
	if dock_isReady():
		assert(test)
		
		# TODO remove Unknown and Unable to process 
		
		var file_name = "_material.tres"
		if material_filename.text != "":
			file_name = material_filename.text + "_material.tres"
		debug(file_name)
		
		var file_content = load_template("res://addons/Lazy_Import/templates/spatialmaterial.header.tres.txt") + "\n\n"
		var step1 = load_template("res://addons/Lazy_Import/templates/spatialmaterial.step1.tres.txt") + "\n\n"
		
		# listado de archivos
		var file_id = 1
		for node in file_list.get_children():
			var N = node.get_node("CheckBox")
			if N is CheckBox && N.pressed == true:
				try_to_fix_file(N.text)
				file_content += step1.replace("%%FILE%%", directory + N.text).replace("%%ID%%", file_id) + "\n"
				file_id += 1
		
		file_content += load_template("res://addons/Lazy_Import/templates/spatialmaterial.step2.tres.txt") + "\n\n"
		
		debug(material_options.text)
		match material_options.text:
			"High Quality":
				file_content += ""
			"Transparent":
				file_content += "flags_transparent = true\n"
			"Low End":
				file_content += "flags_vertex_lighting = true\n"
			"Interface":
				file_content += "flags_no_depth_test = true\nflags_fixed_size = true\nflags_do_not_receive_shadows = true\nflags_disable_ambient_light = true\nparams_specular_mode = 4\nparams_billboard_mode = 1\nparams_billboard_keep_scale = true\n"
			"Hair":
				file_content += "params_diffuse_mode = 2\n"
			"Cloth":
				file_content += "params_diffuse_mode = 3\n"
			"Toon":
				file_content += "params_diffuse_mode = 4\nparams_specular_mode = 3\n"
			"Foliage":
				file_content += "flags_no_depth_test = true\nparams_depth_draw_mode = 3\n"
			"Billboard":
				file_content += "flags_no_depth_test = true\nparams_depth_draw_mode = 3\nparams_billboard_mode = 1\n"
			"Particles":
				file_content += "flags_no_depth_test = true\nparams_billboard_mode = 3\nparticles_anim_h_frames = 1\nparticles_anim_v_frames = 1\nparticles_anim_loop = false\n"
			"Sprite":
				file_content += "flags_no_depth_test = true\nflags_fixed_size = true\nflags_do_not_receive_shadows = true\nparams_specular_mode = 4\nparams_use_alpha_scissor = true\nparams_alpha_scissor_threshold = 0.98\n"
			"Meat":
				file_content += ""
			"Light":
				file_content += "flags_transparent = true\nparams_blend_mode = 1\n"
		
		file_id = 1
		for node in file_list.get_children():
			var N = node.get_node("CheckBox")
			if N is CheckBox && N.pressed == true:
				var O = node.get_node("OptionButton")
				
				match O.text:
					"Unknown": # Albedo, Metallic y Rougness parecen ser obligatorios
						pass
					"Albedo":
						file_content += "albedo_texture = ExtResource( " + str(file_id) + " )\n"
					"Metallic":
						file_content += "metallic_texture = ExtResource( " + str(file_id) + " )\nmetallic = 1.0\nroughness = 0.5\n"
					"Rougness":
						file_content += "roughness_texture = ExtResource( " + str(file_id) + " )\n"
					"Emission":
						file_content += "emission_enabled = true\nemission = Color( 0, 0, 0, 1 )\nemission_energy = 1.0\nemission_operator = 0\nemission_on_uv2 = false\nemission_texture = ExtResource( " + str(file_id) + " )\n"
					"Normal Map":
						file_content += "normal_enabled = true\nnormal_scale = 1.0\nnormal_texture = ExtResource( " + str(file_id) + " )\n"
					"Rim":
						file_content += "rim_enabled = true\nrim = 1.0\nrim_tint = 0.5\nrim_texture = ExtResource( " + str(file_id) + " )\n"
					"Clearcoat":
						file_content += "clearcoat_enabled = true\nclearcoat = 1.0\nclearcoat_gloss = 0.5\nclearcoat_texture = ExtResource( " + str(file_id) + " )\n"
					"Anisotropy":
						file_content += "anisotropy_enabled = true\nanisotropy = 0.0\nanisotropy_flowmap = ExtResource( " + str(file_id) + " )\n"
					"Ambient Occlusion":
						file_content += "ao_enabled = true\nao_light_affect = 0.0\nao_texture = ExtResource( " + str(file_id) + " )\nao_on_uv2 = false\nao_texture_channel = 0\n"
					"Depth":
						file_content += "depth_enabled = true\ndepth_scale = 0.001\ndepth_deep_parallax = false\ndepth_flip_tangent = false\ndepth_flip_binormal = false\ndepth_texture = ExtResource( " + str(file_id) + " )\n"
					"Subsurface Scattering":
						file_content += "params_diffuse_mode = 2\nsubsurf_scatter_enabled = true\nsubsurf_scatter_strength = 0.0\nsubsurf_scatter_texture = ExtResource( " + str(file_id) + " )\n"
					"Transmission":
						file_content += "transmission_enabled = true\ntransmission = Color( 0, 0, 0, 1 )\ntransmission_texture = ExtResource( " + str(file_id) + " )\n"
					"Refraction":
						file_content += "refraction_enabled = true\nrefraction_scale = 0.05\nrefraction_texture = ExtResource( " + str(file_id) + " )\nrefraction_texture_channel = 0\n"
					"Detail":
						file_content += "detail_enabled = true\ndetail_mask = ExtResource( " + str(file_id) + " )\ndetail_blend_mode = 0\ndetail_uv_layer = 0\n"
					"Decal":
						file_content += "flags_no_depth_test = true\n"
					"Need Conversion":
						pass
				
				file_id += 1

		debug(file_name + " - " +  file_content)
		if test:
			print(self.get_script().get_path().get_base_dir() + "/test/test_material.tres")
			save_template(self.get_script().get_path().get_base_dir() + "/test/test_material.tres", file_content)
			notify("Open the Test Scene! " + self.get_script().get_path().get_base_dir() + "/test/tester.tscn")
		else:
			save_template(directory + "/" + file_name, file_content)
		_plugin.filesystem_refresh()
		refresh()



# Signals

func _on_Scenes_pressed():
	debug("_on_Scenes_pressed()")
	if dock_isReady():
		
		var template = load_template("res://addons/Lazy_Import/templates/scene.tscn.txt")
		
		for node in file_list.get_children():
			var N = node.get_node("CheckBox")
			if N is CheckBox && N.pressed == true:
				var file_name = directory + N.text + ".tscn"
				var file_content = template.replace("%%FILE%%", directory + N.text).replace("%%NAME%%", remove_file_extensions(N.text))
				
				debug(file_name + "  :  " + file_content)
				
				save_template(file_name, file_content)
		
		_plugin.filesystem_refresh()
		refresh()


func _on_Materials_pressed():
	debug("_on_Materials_pressed()")
	if dock_isReady():
		create_material(false)


func _on_ToogleAll_pressed():
	debug("_on_ToogleAll_pressed()")
	if dock_isReady():
		
		for node in file_list.get_children():
			var N = node.get_node("CheckBox")
			if N is CheckBox && N.disabled == false:
				N.pressed = toggleAll
		
		toggleAll = !toggleAll
		
		refresh_buttons()


func _on_LineEdit_text_changed(new_text):
	debug("_on_LineEdit_text_changed()")
	if dock_isReady():
		
		if new_text != "":
			search_filter = new_text
		else:
			search_filter = "."
		refresh()


func _on_MaterialName_text_changed(new_text):
	debug("_on_MaterialName_text_changed()")
	if dock_isReady():
		
		pass # Replace with function body.


func _on_Test_pressed():
	debug("_on_Test_pressed()")
	if dock_isReady():
		
		create_material(true)
