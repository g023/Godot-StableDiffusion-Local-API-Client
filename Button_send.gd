extends Button

@onready var g_node_sdimage = $"../../HSplitContainer/TextureRect_sdimage"
@onready var g_node_prompt = $"../../TextEdit_prompt"
@onready var g_node_prompt_negative = $"../../TextEdit_prompt_negative"


@onready var g_n_cfg = $"../../HBoxContainer2/LineEdit_cfg"
@onready var g_n_w = $"../../HBoxContainer2/LineEdit_w"
@onready var g_n_h = $"../../HBoxContainer2/LineEdit_h"
@onready var g_n_step = $"../../HBoxContainer2/LineEdit_steps"
# @onready var g_n_w
@onready var g_n_seed = $"../../HBoxContainer2/LineEdit_seed"
@onready var g_n_facefix = $"../../HBoxContainer2/CheckBox_face"

@onready var g_node_config = $"../../../../Node_pulse_config"


@onready var g_sdimage_progress_node = $"../../HSplitContainer/TextureRect_sdimageProgress"

var g_last_raw = null
var g_last_info = {}
var g_last_ext = ""

var g_busy = false
var g_timem_start = 0
var g_timem_end = 0

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

		
	pass


func _ready():
	# hide progress image
	g_sdimage_progress_node.hide()
	pass # _ready




## BEGIN CRITICAL

func get_api_url():
	var the_url = "http://127.0.0.1:7860/sdapi/v1/txt2img"
	return the_url

## END CRITICAL


func _on_button_up():
	
	var payload = {
		"seed": int(g_n_seed.text),
		"prompt": g_node_prompt.text,
		"negative_prompt":g_node_prompt_negative.text,
		"save_images":false,
		"restore_faces": g_n_facefix.button_pressed,
		"tiling": false,
		"steps": int(g_n_step.text),
		"width": int(g_n_w.text),
		"height": int(g_n_h.text),
		"cfg_scale":float (g_n_cfg.text),
		"sampler_name":"LMS Karras", # 'DPM++ 2M Karras', 'DPM++ SDE Karras', 'DPM++ 2M SDE Exponential', 'DPM++ 2M SDE Karras', 'Euler a', 'Euler', 'LMS', 'Heun', 'DPM2', 'DPM2 a', 'DPM++ 2S a', 'DPM++ 2M', 'DPM++ SDE', 'DPM++ 2M SDE', 'DPM++ 2M SDE Heun', 'DPM++ 2M SDE Heun Karras', 'DPM++ 2M SDE Heun Exponential', 'DPM++ 3M SDE', 'DPM++ 3M SDE Karras', 'DPM++ 3M SDE Exponential', 'DPM fast', 'DPM adaptive', 'LMS Karras', 'DPM2 Karras', 'DPM2 a Karras', 'DPM++ 2S a Karras', 'Restart', 'DDIM', 'PLMS', 'UniPC']"}
		"sampler_index":"LMS Karras", # 'DPM++ 2M Karras', 'DPM++ SDE Karras', 'DPM++ 2M SDE Exponential', 'DPM++ 2M SDE Karras', 'Euler a', 'Euler', 'LMS', 'Heun', 'DPM2', 'DPM2 a', 'DPM++ 2S a', 'DPM++ 2M', 'DPM++ SDE', 'DPM++ 2M SDE', 'DPM++ 2M SDE Heun', 'DPM++ 2M SDE Heun Karras', 'DPM++ 2M SDE Heun Exponential', 'DPM++ 3M SDE', 'DPM++ 3M SDE Karras', 'DPM++ 3M SDE Exponential', 'DPM fast', 'DPM adaptive', 'LMS Karras', 'DPM2 Karras', 'DPM2 a Karras', 'DPM++ 2S a Karras', 'Restart', 'DDIM', 'PLMS', 'UniPC']"}
	}
	
	print("sending payload:", JSON.stringify(payload))
	g_timem_start = Time.get_ticks_msec()
	
	SD_send_POST_request(payload, done_request)

func SD_send_POST_request(payload, callback_func):
	if g_busy == true:
		print("currently busy serving last request")
		return
	
	g_busy = true
	var url = get_api_url()
	$HTTPRequest.request_completed.connect(callback_func)
	var send_request = $HTTPRequest.request(url,[],HTTPClient.METHOD_POST, JSON.stringify(payload)) # what do we want to connect to

	if send_request != OK:
		g_busy = false
		print("ERROR sending request")


# Create a new Texture from base64 data
func create_texture_from_base64(base64_string: String) -> Texture:
	var image_data = Marshalls.base64_to_raw(base64_string)
	var image = Image.new()
	# var error = image.load_png_from_buffer(image_data)
	
# var error = image.load_jpg_from_buffer(image_data)
	var error = null
	var raw_data = Marshalls.base64_to_raw(base64_string)
	if g_node_config.g_filetype == "png":
		error = image.load_png_from_buffer(raw_data)
	else: # jpg
		error = image.load_jpg_from_buffer(raw_data)
			
	if error != OK:
		print("Error loading image:", error)
		return null
		
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture


func done_request(result, response_code, headers, body):
	g_busy = false
	
	g_timem_end = Time.get_ticks_msec()
	
	var diff_time = g_timem_end - g_timem_start
	
	print('result:\n', result)
	# print('body:\n', body)
	var r = JSON.parse_string(body.get_string_from_utf8())
	
	if r != null and r.has("info"):
		var info = r["info"]
		var params = r["parameters"]
		
		var seed = JSON.parse_string(info)["seed"]
		var model = JSON.parse_string(info)["sd_model_name"]

		var prompt = JSON.parse_string(info)["prompt"]
		var negative_prompt = JSON.parse_string(info)["negative_prompt"]

		var steps = params["steps"]		
		var cfg = params["cfg_scale"]		
		var width = params["width"]
		var height = params["height"]
		var restore_faces = params["restore_faces"]
	
		print("info:\n", info,"\n\n")
		print("params:\n", params,"\n\n")
		print("seed:", seed)
		print("model:", model)

		g_last_info.info = JSON.parse_string(info)
		g_last_info.params = params
		g_last_info.seed = seed
		g_last_info.model = model
		g_last_info.cfg = cfg
		g_last_info.w = width
		g_last_info.h = height
		g_last_info.restore_faces = restore_faces
		g_last_info.steps = steps


		var img_base64 = r['images'][0]
		# print("img:\n", img)
		var raw_data = Marshalls.base64_to_raw(img_base64)

		# store some data for saving
		g_last_raw = raw_data

		## xx save .jpg as binary
		#var f = FileAccess.open("./temp/temp_image.jpg", FileAccess.WRITE)
#
		#for byte in raw_data:
			#f.store_8(byte)
		#f.close()
		## xx end :: save .jpg as binary
		
		#var path = "./temp/temp_image.jpg"
		#var image_loaded = Image.load_from_file(path)
		#var texture = ImageTexture.create_from_image(image_loaded)
		#g_node_sdimage.texture = texture	

		# new way to just convert from memory
		var jpg_image = Image.new()
		jpg_image.load_jpg_from_buffer(raw_data)
		var error = null
		
		
		if g_node_config.g_filetype == "png":
			error = jpg_image.load_png_from_buffer(raw_data)
			g_last_ext = "png"
		else: # jpg
			error = jpg_image.load_jpg_from_buffer(raw_data)
			g_last_ext = "jpg"
				
		if error != OK:
			print("Error loading image:", error)
			return null
				
		var textureb = ImageTexture.create_from_image(jpg_image)
		g_node_sdimage.texture = textureb	
		
		# hide our progress image
		g_sdimage_progress_node.hide()

		r["images"] = "" # we don't want to see the image in our debug
		print("response:\n",JSON.stringify(r),"\n***\n")

		var total_seconds = float(diff_time / 1000)
		print("time taken:", total_seconds, " seconds")

		print("steps:", steps)
		print("steps per second:", total_seconds/ steps)

	pass
	 

