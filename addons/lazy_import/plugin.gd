tool
extends "boilerplate core/EditorPlugin.inheritance.gd"


###############################
#   Lazy Plugin Boilerplate   #
###############################


func _init(): plugin_scope = self


###### YOUR PLUGIN'S CODE


var dock = preload("do not export tools/dock.tscn").instance()
var PluginDockName = "Lazy Import"
var resources

var interface = get_editor_interface()
var fileSystem = interface.get_resource_filesystem()
var fileSystemDock = interface.get_file_system_dock()

signal material_changed
var test_scene_path = "res://addons/lazy_import/do not export tools/Material.Test.tscn"
var test_material_path = "res://addons/lazy_import/do not export tools/Scenes/Room/white.material"
var test_material_name = "test_material"
var material_previewing = test_material_name


func deferred_enter_tree():
	resources = ResourcePreloader.new()
	resources.name = "LazyImportResources"
	self.add_child(resources)
	
	#dock = preload("res://addons/Lazy_Import/core/dock.tscn").instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	
	if dock != null:
		# añadismo las señales
		fileSystem.connect("filesystem_changed", self, "remote_refresh_by_filesystem_changed")
		#fileSystem.connect("resources_reimported", self, "refresh")
		#fileSystem.connect("resources_reload", self, "refresh")
		#fileSystem.connect("sources_changed", self, "remote_refresh_by_filesystem_changed")
		fileSystemDock.connect("display_mode_changed", self, "remote_refresh_by_display_mode_changed")
		subscribe_to_trees()
	
		remote_refresh("_enter_tree")
		#material_preview()


func deferred_exit_tree():
	remove_control_from_docks(dock)
	if dock != null: dock.queue_free()
	resources.queue_free()
	self.queue_free()


func check_string(variable : String):
	assert(variable)
	if variable == "" || variable.empty():
		singleton.error("string should not be empty")
		return false
	else:
		return true


func material_preview(material_name = test_material_name, file_path = test_material_path):
	if check_string(material_name) && check_string(file_path):
		material_previewing = material_name
		# verificar si el resource existe
		if not resources.has_resource(material_name):
			resources.add_resource(material_name, load(file_path))

		# emitir señal actualiación (tonteria, podría haber recargado la escena)
		emit_signal("material_changed")
		
	interface.open_scene_from_path(test_scene_path)
	interface.set_main_screen_editor("3D")



func remote_refresh(from):
	if dock:
		dock.refresh(from)

func filesystem_refresh():
	fileSystem.scan()

func selected_path():
	return interface.get_selected_path()

func subscribe_to_trees(node = fileSystemDock):
	for N in node.get_children():
		if N.get_child_count() > 0:
			if N is Tree:
				N.connect("cell_selected", self, "remote_refresh_by_tree_cell_selected")
			subscribe_to_trees(N)
		elif N is Tree:
			N.connect("cell_selected", self, "remote_refresh_by_tree_cell_selected")


func remote_refresh_by_filesystem_changed():
	remote_refresh("filesystem_changed")

func remote_refresh_by_tree_cell_selected():
	remote_refresh("filesystemDock Tree cell_selected")
	
func remote_refresh_by_display_mode_changed():
	remote_refresh("filesystemDock mode changed")

