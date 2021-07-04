tool
extends Node


onready var singleton = $"/root/lazy_import"
onready var plugin = $"/root/EditorNode".get_node("lazy_import")


var tween_pos = Tween.new()
var tween_rot = Tween.new()
var tween_values = [Vector3 (), Vector3 ()]
export var start = Vector3 ()
export var end = Vector3 ()
export var rotate = true


func _ready():
	plugin.connect("material_changed", self, "_on_material_changed")
	
	self.translation = start
	self.rotation = Vector3.ZERO
	add_child(tween_pos)
	add_child(tween_rot)
	tween_pos.connect("tween_completed", self, "_on_tween_pos_completed")
	tween_rot.connect("tween_completed", self, "_on_tween_rot_completed")
	tween_values[0] = start
	tween_values[1] = end
	
	#configure_materials(plugin.material_previewing)
	
	# be ordered please!
	yield(get_tree().create_timer((self.get_index()+1)*(10/3)), "timeout")
	
	_start_tween_pos()
	if rotate: _start_tween_rot()


func configure_materials(material_name : String = "test_material", nodo = self):
	if plugin.check_string(material_name):
		if plugin.resources != null:
			var material = plugin.resources.get_resource(material_name)
			
			for N in nodo.get_children():
				if N.get_child_count() > 0:
					if N is MeshInstance:
						#print(N.name)
						N.set_material_override(material)
					configure_materials(material_name, N)
				elif N is MeshInstance:
					N.set_material_override(material)
					#print(N.name)
		else:
			plugin.error("Materials cannot been set")


func _start_tween_pos():
	tween_pos.interpolate_property(self, "translation", tween_values[0], tween_values[1], 10, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()

func _start_tween_rot():
	tween_rot.interpolate_property(self, "rotation", Vector3.ZERO, Vector3(360,360,360), 1000, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_rot.start()

func _on_tween_pos_completed(object, key):
	tween_values.invert()
	_start_tween_pos()

func _on_tween_rot_completed(object, key):
	_start_tween_rot()

func _on_material_changed():
	configure_materials(plugin.material_previewing)
