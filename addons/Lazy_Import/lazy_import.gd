tool
extends EditorPlugin


var dock
var debug = false
var debugTitle = "Lazy Import - lazy_import.gd: "
var error = "Lazy Import Dock is not behaving properly! Try to restart Godot!"

var interface = get_editor_interface()
var fileSystem = interface.get_resource_filesystem()
var fileSystemDock = interface.get_file_system_dock()

func _enter_tree():
	if debug: print(debugTitle + "_enter_tree()")
	
	self.set_name("Lazy Import Plugin")
	if debug: print(debugTitle + self.name + " loaded")
	if debug: print(debugTitle + self.get_path())
	
	dock = preload("res://addons/Lazy_Import/dock.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	
	if dock is Node && "plugin" in dock:
		dock.plugin = self
		dock.plugin_ready = true
		dock.debug = debug
	
		# añadismo las señales
		fileSystem.connect("filesystem_changed", self, "refresh")
		#fileSystem.connect("resources_reimported", self, "refresh")
		#fileSystem.connect("resources_reload", self, "refresh")
		#fileSystem.connect("sources_changed", self, "refresh")
		fileSystemDock.connect("display_mode_changed", self, "refresh")
		subscribe_to_trees()
		
		refresh()
	else:
		push_error(error)

func _exit_tree():
	if debug: print(debugTitle + "_exit_tree()")
	remove_control_from_docks(dock)
	if (dock is Node && dock.has_method("kill")): dock.kill()
	self.queue_free()


func refresh():
	if debug: print(debugTitle + "refresh()")
	if (dock is Node && dock.has_method("refresh")):
		dock.refresh()
	else:
		push_error(error)

func filesystem_refresh():
	fileSystem.scan()

func selected_path():
	if debug: print(debugTitle + "selected_path()")
	return interface.get_selected_path()

func get_plugin_name():
	if debug: print(debugTitle + "get_plugin_name()")
	return "Lazy_Import" # es el nombre del directorio

func is_enabled():
	if debug: print(debugTitle + "is_enabled() " + get_plugin_name())
	return interface.is_plugin_enabled(get_plugin_name())


func subscribe_to_trees(node = fileSystemDock):
	if debug: print(debugTitle + "subscribe_to_trees()")
	for N in node.get_children():
		if N.get_child_count() > 0:
			if N is Tree:
				N.connect("cell_selected", self, "refresh")
				if debug: print(debugTitle + N.get_name() + " " + N.get_class())
			subscribe_to_trees(N)
		elif N is Tree:
			N.connect("cell_selected", self, "refresh")
			if debug: print(debugTitle + N.get_name() + " " + N.get_class())
