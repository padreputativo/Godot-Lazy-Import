tool
extends EditorPlugin


#############################
#  Lazy Plugin Boilerplate  #
# PLEASE DO NOT MODIFY THIS #
#############################


const singleton_to_instance = preload("../singleton.gd")
var singleton
var plugin_scope


func _enter_tree():
	instantiate_singleton()

func _exit_tree():
	if singleton:
		singleton.queue_free()
		remove_autoload_singleton(singleton.DIR_NAME)
	
	if plugin_scope: plugin_scope.deferred_exit_tree()


func instantiate_singleton():
	# Instance
	singleton = singleton_to_instance.new()
	# Change the Node Name
	singleton.set_name(singleton.DIR_NAME)
	# Add the Node as a Singleton
	get_tree().get_root().call_deferred("add_child", singleton)
	# Start your plugin
	singleton.connect("ready", self, "_on_singleton_ready")


func _on_singleton_ready():
	if not singleton:
		print ("Plugin singleton is not loaded properly")
	elif not check_editor_configuration():
		singleton.error("Wrong configuration")
	else:
		plugin_scope.name = singleton.DIR_NAME
		add_autoload_singleton(singleton.DIR_NAME, singleton.ADDON_DIR + "singleton.gd")
		
		if plugin_scope: plugin_scope.deferred_enter_tree()


func check_editor_configuration() -> bool:
	if singleton:
		if singleton.name != singleton.DIR_NAME: # checks if this is the first instance
			singleton.error("Singleton should be called '" + singleton.DIR_NAME+"' to be found, instead '"+singleton.name+"'")
		elif singleton != get_tree().get_root().get_node(singleton.DIR_NAME):
			singleton.error("Singleton is not properly instantiaded")
		elif not get_editor_interface().is_plugin_enabled(singleton.DIR_NAME): # checks if the plugin is turned on
			singleton.error("The plugin is not turned on! This should not be running!")
		elif plugin_scope.get_script().get_path().get_base_dir() != "res://addons/" + singleton.DIR_NAME: # check if the plugin is properly located
			singleton.error(plugin_scope.get_script().get_path().get_base_dir() + " should be res://addons/" + singleton.DIR_NAME)
		elif Engine.get_version_info().major != singleton.MIN_GODOT_VERSION_MAYOR:
			singleton.error(str(Engine.get_version_info().major) + " should be " + str(singleton.MIN_GODOT_VERSION_MAYOR))
		elif Engine.get_version_info().minor <= singleton.MIN_GODOT_VERSION_MINOR:
			singleton.error(str(Engine.get_version_info().minor) + " should be >= " + str(singleton.MIN_GODOT_VERSION_MINOR))
		elif Engine.get_version_info().patch <= singleton.MIN_GODOT_VERSION_PATCH:
			singleton.error(str(Engine.get_version_info().patch) + " should be >= " + str(singleton.MIN_GODOT_VERSION_PATCH))
		else:
			for _plugin in singleton.REQUIRED_PLUGINS_DIR_NAMES:
				if not get_editor_interface().is_plugin_enabled(_plugin):
					singleton.error(_plugin + " plugin is required to run this plugin!")
					return false
			return true
	
	return false
