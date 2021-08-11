extends "../boilerplate.gd"


#############################
#  Lazy Plugin Boilerplate  #
# PLEASE DO NOT MODIFY THIS #
#############################


func error(msg):
	return push_error(PLUGIN_NAME + " ERROR : " + msg)


func warning(msg):
	return push_warning(PLUGIN_NAME + " Warning : " + msg)


func notify(msg):
	return print(PLUGIN_NAME + " : " + msg)
