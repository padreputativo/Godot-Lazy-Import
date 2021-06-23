tool
extends EditorPlugin

const DEBUG_MODE = false
const PluginName = "Lazy Import Plugin"
const PluginDockName = "Lazy Import"

var dock
var resources

var interface = get_editor_interface()
var fileSystem = interface.get_resource_filesystem()
var fileSystemDock = interface.get_file_system_dock()

signal material_changed
var test_scene_path = "res://addons/Lazy_Import/Lazy Import.tscn"
var test_material_path = "res://addons/Lazy_Import/Scenes/Basic.material"
var test_material_name = "test_material"
var material_previewing = test_material_name

func _enter_tree():
	debug("_enter_tree()")
	
	self.set_name(PluginName)
	debug(self.name + " loaded")
	debug(self.get_path())

	
	#print("Creando ResourcePreloader")
	resources = ResourcePreloader.new()
	resources.name = "LazyImportResources"
	self.add_child(resources)
	#yield(get_tree().get_root(), "ready")
	#get_tree().get_root().add_child(resources)
	#get_tree().get_root().call_deferred("add_child", resources)
	#print(resources.get_path())
	#print(resources.name)
	#if resources is ResourcePreloader: print("Es de tipo ResourcePreloader")
	
	if plugin_isReady():
		dock = preload("res://addons/Lazy_Import/core/dock.tscn").instance()
		
		add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
		if dock_isReady():
			# añadismo las señales
			fileSystem.connect("filesystem_changed", self, "remote_refresh_by_filesystem_changed")
			#fileSystem.connect("resources_reimported", self, "refresh")
			#fileSystem.connect("resources_reload", self, "refresh")
			#fileSystem.connect("sources_changed", self, "remote_refresh_by_filesystem_changed")
			fileSystemDock.connect("display_mode_changed", self, "remote_refresh_by_display_mode_changed")
			subscribe_to_trees()
		
			remote_refresh("_enter_tree")
			material_preview()

func _exit_tree():
	debug("_exit_tree()")
	remove_control_from_docks(dock)
	if dock_isReady() && dock.has_method("kill"): dock.queue_free()
	resources.queue_free()
	self.queue_free()

func that():
	return self
	
func debug(txt):
	if DEBUG_MODE: print("Lazy Import : " + txt)

func notify(txt):
	push_warning("Lazy Import : " + txt)

func error(txt):
	push_error("Lazy Import : " + txt)


func dock_isReady():
	if dock is Node && dock.name == PluginDockName: # el nombre se setea en el ready asi que esto comprueba si ya está en ejecución
		return true
	else:
		var name = "unknown"
		if dock: name = dock.name
		error("Dock is not behaving properly! _" + name + "_")

func plugin_isReady():
	if self is EditorPlugin && self.name == PluginName && interface.is_plugin_enabled(get_plugin_name()):
		return true
	else:
		error("Plugin is not behaving properly! _" + self.name + "_")


func check_string(variable : String):
	assert(variable)
	if variable == "":
		push_error("Lazy Import Plugin: check error")
		return false
	else:
		return true
		



func material_preview(material_name = test_material_name, file_path = test_material_path):
	debug("material_preview() " + material_name)
	if check_string(material_name) && check_string(file_path):
		material_previewing = material_name
		# verificar si el resource existe
		if not resources.has_resource(material_name):
			debug("Adding " + material_name + " to resources at " + file_path)
			resources.add_resource(material_name, load(file_path))

		# emitir señal actualiación (tonteria, podría haber recargado la escena)
		emit_signal("material_changed")
		
	interface.open_scene_from_path(test_scene_path)
	interface.set_main_screen_editor("3D")



func remote_refresh(from):
	debug("remote_refresh()")
	if plugin_isReady() && dock_isReady():
		dock.refresh(from)

func filesystem_refresh():
	debug("filesystem_refresh()")
	if plugin_isReady():
		fileSystem.scan()

func selected_path():
	debug("selected_path()")
	return interface.get_selected_path()

func get_plugin_name():
	debug("get_plugin_name()")
	return "Lazy_Import" # es el nombre del directorio


func subscribe_to_trees(node = fileSystemDock):
	debug("subscribe_to_trees()")
	if plugin_isReady() && dock_isReady():
		for N in node.get_children():
			if N.get_child_count() > 0:
				if N is Tree:
					N.connect("cell_selected", self, "remote_refresh_by_tree_cell_selected")
					debug(N.get_name() + " " + N.get_class())
				subscribe_to_trees(N)
			elif N is Tree:
				N.connect("cell_selected", self, "remote_refresh_by_tree_cell_selected")
				debug(N.get_name() + " " + N.get_class())


func remote_refresh_by_filesystem_changed():
	remote_refresh("filesystem_changed")

func remote_refresh_by_tree_cell_selected():
	remote_refresh("filesystemDock Tree cell_selected")
	
func remote_refresh_by_display_mode_changed():
	remote_refresh("filesystemDock mode changed")
