tool
extends EditorPlugin


var dock
var debug = false

var interface = get_editor_interface()
var fileSystem = interface.get_resource_filesystem()
var fileSystemDock = interface.get_file_system_dock()

func _enter_tree():
	debug("_enter_tree()")
	
	self.set_name("Lazy Import Plugin")
	debug(self.name + " loaded")
	debug(self.get_path())
	
	if plugin_isReady():
		dock = preload("res://addons/Lazy_Import/dock.tscn").instance()
		add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
		
		if dock_isReady():
			dock._plugin = self
			dock._plugin_ready = true
			dock._debug = debug
		
			# añadismo las señales
			fileSystem.connect("filesystem_changed", self, "refresh")
			#fileSystem.connect("resources_reimported", self, "refresh")
			#fileSystem.connect("resources_reload", self, "refresh")
			#fileSystem.connect("sources_changed", self, "refresh")
			fileSystemDock.connect("display_mode_changed", self, "refresh")
			subscribe_to_trees()
			
			refresh()

func _exit_tree():
	debug("_exit_tree()")
	remove_control_from_docks(dock)
	dock.kill()
	self.queue_free()


func dock_isReady():
	if dock is Node && dock.name == "Lazy Import": # el nombre se setea en el ready asi que esto comprueba si ya está en ejecución
		return true
	else:
		push_error("Lazy Import Dock is not behaving properly! Try to restart Godot!")

func plugin_isReady():
	if self is EditorPlugin && self.name == "Lazy Import Plugin" && is_enabled():
		return true
	else:
		push_error("Lazy Import Plugin is not behaving properly! Try to restart Godot!")

func debug(txt):
	if debug: print("Lazy Import Plugin : " + txt)

func refresh():
	debug("refresh()")
	if plugin_isReady() && dock_isReady():
		dock.refresh()

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

func is_enabled():
	debug("is_enabled() " + get_plugin_name())
	return interface.is_plugin_enabled(get_plugin_name())


func subscribe_to_trees(node = fileSystemDock):
	debug("subscribe_to_trees()")
	if plugin_isReady() && dock_isReady():
		for N in node.get_children():
			if N.get_child_count() > 0:
				if N is Tree:
					N.connect("cell_selected", self, "refresh")
					debug(N.get_name() + " " + N.get_class())
				subscribe_to_trees(N)
			elif N is Tree:
				N.connect("cell_selected", self, "refresh")
				debug(N.get_name() + " " + N.get_class())
