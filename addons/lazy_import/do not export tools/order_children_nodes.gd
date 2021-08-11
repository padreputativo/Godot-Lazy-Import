tool
extends Node


onready var singleton = $"/root/lazy_import"

export (bool) var order_on_ready = true
export (float) var cell_size = 5

func _ready():
	if order_on_ready:
		singleton.notify("Ordering children nodes...")
		
		var x = 0.0
		var z = 0.0
		
		for sceneNode in self.get_children():
			sceneNode.set_translation(Vector3(x, 0.0, z))

			z += cell_size * 1
			if(z==(cell_size * 10)):
				z = 0.0
				x += cell_size * 1
