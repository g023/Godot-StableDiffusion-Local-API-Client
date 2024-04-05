extends LineEdit

@onready var g_node_config = $"../../../../Node_pulse_config"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var str = ""
	str += " Type:." + g_node_config.g_filetype
	str += " Model:" + g_node_config.g_model + " "
	text = str
	pass
