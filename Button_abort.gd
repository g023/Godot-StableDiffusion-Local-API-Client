extends Button

@onready var g_node_sdimage = $"../../HSplitContainer/TextureRect_sdimage"

var g_busy = false

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

		
	pass


func _ready():
	pass # _ready




## BEGIN CRITICAL

func get_api_url_interrupt():
	var the_url = "http://127.0.0.1:7860/sdapi/v1/interrupt"
	return the_url

## END CRITICAL


func _on_button_up():
	
	var payload = {
	}
	
	SD_send_POST_request(get_api_url_interrupt(), payload, done_request)

func SD_send_POST_request(url, payload, callback_func):
	$HTTPRequest.request_completed.connect(callback_func)
	var send_request = $HTTPRequest.request(url,[],HTTPClient.METHOD_POST, JSON.stringify(payload)) # what do we want to connect to

	if send_request != OK:
		print("ERROR sending request")


func done_request(result, response_code, headers, body):
	print("done interrupting")

	pass
	 

