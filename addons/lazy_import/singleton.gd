extends "boilerplate core/SingletonNode.inheritance.gd"


#############################
#  Lazy Plugin Boilerplate  #
#############################


onready var singleton = $"/root/lazy_import"

func _ready():
	# You have some extra methods: singleton.notify(string), singleton.warning(string), singleton.error(string)
	singleton.notify("The plugin is running!")
