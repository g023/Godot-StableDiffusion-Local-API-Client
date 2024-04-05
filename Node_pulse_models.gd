extends Node


@onready var g_node_error_noserver = $"../CanvasLayer/Window_ERROR_noserver"


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


func get_api_url_options():
	return "http://127.0.0.1:7860/sdapi/v1/sd-models"

func do_timer():
	SD_send_GET_request(get_api_url_options(), {}, do_timer_response)
	print("do timer")


var g_last_64 = ""
func do_timer_response(result, response_code, headers, body):
	# get the progress and update the progress bar
	var r = JSON.parse_string(body.get_string_from_utf8())
	
	print("idle:models")
	#print(r)
	
	for model in r:
		print(model.model_name)
		print(model.title) # filename
		print(model.filename) # path
		print("-=-")
	
	if r == null:
		# print("Server not started.")
		return
	else:
		# we have a response from server
		pass


func _on_timer_timeout():
	do_timer()
	pass # Replace with function body.


func _on_ready():
	SD_send_GET_request(get_api_url_options(), {}, do_timer_response)
	print("do timer:models")
	pass # Replace with function body.
