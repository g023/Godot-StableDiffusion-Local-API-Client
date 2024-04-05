extends Node

@onready var g_progress_bar_node = $"../CanvasLayer/VBoxContainer/ProgressBar"

@onready var g_sdimage_progress_node = $"../CanvasLayer/VBoxContainer/HSplitContainer/TextureRect_sdimageProgress"

@onready var g_node_error_noserver = $"../CanvasLayer/Window_ERROR_noserver"

@onready var g_node_config = $"../Node_pulse_config"


func base64_to_jpg(the_base64:String, the_image_path:String):
	var raw_data = Marshalls.base64_to_raw(the_base64)
	
	## xx save .jpg as binary
	var f = FileAccess.open(the_image_path, FileAccess.WRITE)

	for byte in raw_data:
		f.store_8(byte)
	f.close()
	## xx end :: save .jpg as binary

func imagefile_to_texture(the_image_path:String):
	var image_loaded = Image.load_from_file(the_image_path)
	var texture = ImageTexture.create_from_image(image_loaded)
	return texture


var g_busy = false
func SD_send_GET_request(url, payload, callback_func):
	$HTTPRequest.request_completed.connect(callback_func)
	var send_request = $HTTPRequest.request(url,[],HTTPClient.METHOD_GET, JSON.stringify(payload)) # what do we want to connect to
	
	if send_request != OK:
		g_busy = false
		print("ERROR sending request")
		print("SERVER NOT STARTED")
		g_node_error_noserver.show()
	else:
		g_node_error_noserver.hide()


func get_api_url_progress():
	return "http://127.0.0.1:7860/sdapi/v1/progress"



func do_timer():
	SD_send_GET_request(get_api_url_progress(), {}, do_timer_response)
	print("do timer")


var g_last_64 = ""
func do_timer_response(result, response_code, headers, body):
	# get the progress and update the progress bar
	var r = JSON.parse_string(body.get_string_from_utf8())
	
	if r != null and r.has("current_image"):
		if r["current_image"] == null:
			print("idle")
			g_progress_bar_node.value = 100
			return false
			
	# print(r)
	
	if r == null:
		print("Server not started.")
		return
	
		
	# print(r)
	
	if r.has("current_image"):
		var b64_image = r["current_image"]
		
		if g_last_64 != b64_image: # prevent abusive unnecessary writes
			# mem based
			var raw_data = Marshalls.base64_to_raw(b64_image)
			var jpg_image = Image.new()
			
			# dont use webp
			
			# show our progress image
			g_sdimage_progress_node.show()
			
			print("adjusting for filetype:", g_node_config.g_filetype)
			# png
			if g_node_config.g_filetype == "png":
				jpg_image.load_png_from_buffer(raw_data)
			else: # jpg
				jpg_image.load_jpg_from_buffer(raw_data)
			
			var textureb = ImageTexture.create_from_image(jpg_image)
			g_sdimage_progress_node.texture = textureb
		
			# file based
			#base64_to_jpg(b64_image, "./temp/temp_progress.jpg")
			#var tex = imagefile_to_texture("./temp/temp_progress.jpg")
			#g_sdimage_progress_node.texture = tex
			#g_last_64 = b64_image
			#print("updating image progress")
			## resize g_sdimage_progress_node to fit the image
			#var image_size = tex.get_size()
			#print("progress image size:")
			#print(image_size)
		
		print("time taken:", r["progress"])
		print("time remaining:", r["eta_relative"])
		print("sampling step:", r["state"]["sampling_step"])
		print("sampling steps:", r["state"]["sampling_steps"])
		
		var cur_progress = float(r["state"]["sampling_step"]) / float(r["state"]["sampling_steps"])
		cur_progress = cur_progress * 100
		g_progress_bar_node.value = cur_progress
	

	pass


func _on_timer_timeout():
	do_timer()
	pass # Replace with function body.


func _on_ready():
	g_sdimage_progress_node.hide()
	SD_send_GET_request(get_api_url_progress(), {}, do_timer_response)
	print("do timer:start")
	pass # Replace with function body.
