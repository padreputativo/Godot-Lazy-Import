extends "_CONFIG.gd"

#############################
#  Lazy Plugin Boilerplate  #
#    Configuration  File    #
#############################


######
###### WARNING!!! THIS FILE IS INTENDED FOR THE PLUGIN OWNER ONLY!
######
###### STEP 1: Rename the plugin directory
###### STEP 2: Edit your plugin.cfg file going to Project / Project Settings / Plugins (Tab) / Edit
###### STEP 3: Configure the plugin here:
const PLUGIN_NAME = "Lazy Import" # The name used in your plugin's messages
const DIR_NAME = "lazy_import" # You MUST use underscores instead of spaces and use lower case = snake_case
const ADDON_DIR = "res://addons/" + DIR_NAME + "/" # Do not change this line

# Check https://semver.org/ to understand Semantic Versioning
const MIN_GODOT_VERSION_MAYOR = 3
const MIN_GODOT_VERSION_MINOR = 0
const MIN_GODOT_VERSION_PATCH = 0

# Add your plugin dependencies
# Use the other plugin's directories which this plugin needs to run properly
# We cannot do version control yet
const REQUIRED_PLUGINS_DIR_NAMES = [DIR_NAME, "lazy_import"]

###### STEP 4: Remove plugin.gd and use a Template file to create again your own plugin.gd
# Right clicks in your plugin's directory and create New Script, select a Template, name it plugin.gd

###### STEP 5: Code your singleton.gd to share information all over your scripts

const AUTOLOAD_SINGLETON = false # This will AutoLoad your singleton.gd scripts into your gameplay

###### STEP 6: Create another editor's tool file using a Template File

###### STEP 7: Use the _CONFIG.gd to offer configuration constants to your users

###### STEP 8: Delete all files having names finishing in '_example.gd'
# Those are located inside 'do not export tools' and 'export ingame scripts'

###### STEP 9: Upload it to the Godot Asset Library

###### STEP 10: Be happy for ever and ever


###### DETAILED INFORMATION
#
# What is 'do not export tools'?
#
# Do not Export is a future polyfill of a missing functionality
# For now, Godot is not able to show and run directories without being exported in the final release
# This directory name is created to made you think about this
# Why a final release should have inside the Editor oriented assets?
# I created this to made clear what parts of your plugin are 'exportable' and what are not
# All files related to the Editor functionalities should be inside this dir and not exported

#
# What is .gdignore?
#
# It is the actual (Godot 3.3) way to hide files, but the files allocated there will not been shown
# in the Editor at all and either exported similar to other unrecognized files
# This is why this information is stored here and not in a .txt

#
# What is 'boilerplate core'?
#
# Lazy Plugin Boilerplate have the ability to be updated
# and that is why you can download it again and update the core files
# because everything been split in different directories
# So your plugin functionality will keep intact

#
# What is 'export ingame scripts'?
# 
# If your plugin creates a singleton, it will affect gameplay processes, so then
# it would been exported in the final game release
#
