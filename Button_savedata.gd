extends Button

@onready var g_node_send = $"../../HBoxContainer/Button_send"
# g_last_info is what we need to dump

@onready var g_node_config = $"../../../../Node_pulse_config"

@onready var g_node_fdsave = $"../../../../FileDialog_save"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func save_last_to_path(path:String):
	if g_node_send.g_last_raw == null:
		print("nothing generated")
		return false
	else:	
		var data_to_save = g_node_send.g_last_info
		var file = FileAccess.open(path, FileAccess.WRITE)
		# file.store_var(data_to_save) # binary serialized
		file.store_string(JSON.stringify(data_to_save))

		return true

func return_from_dialog(path):
	print("*** returned from save:", path)
	save_last_to_path(path)
	pass

func _on_button_up():
	if g_node_send.g_last_raw == null:
		print("nothing generated")
		return 
		
	g_node_fdsave.filters = PackedStringArray(["*.json"])
	g_node_fdsave.g_cur_action = "savedata"
	g_node_fdsave.show()	
