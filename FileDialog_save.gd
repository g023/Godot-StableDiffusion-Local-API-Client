extends FileDialog

@onready var g_node_saveimage = $"../CanvasLayer/VBoxContainer/HBoxContainer_save/Button_saveimage"
@onready var g_node_savedata = $"../CanvasLayer/VBoxContainer/HBoxContainer_save/Button_savedata"

var g_cur_action = "saveimage" # so we know how to process a select

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	



func _on_file_selected(path):
	if g_cur_action == "saveimage":
		g_node_saveimage.return_from_dialog(path)
	if g_cur_action == "savedata":
		g_node_savedata.return_from_dialog(path)

	pass # Replace with function body.
