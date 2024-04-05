extends Button

@onready var g_node_send = $"../../HBoxContainer/Button_send"

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
		var f = null
		#if g_node_config.g_filetype == "png":
			#f = FileAccess.open("./temp/temp_image.png", FileAccess.WRITE)
		#else: # jpg
			#f = FileAccess.open("./temp/temp_image.jpg", FileAccess.WRITE)
				
		# store the bytes
		f = FileAccess.open(path, FileAccess.WRITE)
		# should error check.. TODO: 
		for byte in g_node_send.g_last_raw:
			f.store_8(byte)
		f.close()
		return true

func return_from_dialog(path):
	print("*** returned from save:", path)
	save_last_to_path(path)
	pass

func _on_button_up():
	# TODO: add in save_last_to_path
	# save_last_to_path("./temp/temp_image.jpg")
	
	# set filters on filedialog depending on what format we are allowing for gen
	if g_node_send.g_last_raw == null:
		print("nothing generated")
		return 
		
	if g_node_send.g_last_ext == "png":
		g_node_fdsave.filters = PackedStringArray(["*.png"])
	else: # jpg
		g_node_fdsave.filters = PackedStringArray(["*.jpg"])
	
	g_node_fdsave.g_cur_action = "saveimage"
	g_node_fdsave.show()
	
	return
	
	if g_node_send.g_last_raw == null:
		print("nothing generated")
	else:	
		var f = null
		if g_node_send.g_last_ext == "png":
			f = FileAccess.open("./temp/temp_image.png", FileAccess.WRITE)
		else: # jpg
			f = FileAccess.open("./temp/temp_image.jpg", FileAccess.WRITE)
				
		# store the bytes
		for byte in g_node_send.g_last_raw:
			f.store_8(byte)
		f.close()
		
	pass # Replace with function body.
