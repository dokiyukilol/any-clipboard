extends Node
signal enet_status_changed(status:String)
signal peers_changed(peers:Dictionary)
var peer:ENetMultiplayerPeer
var server:String
var debug = true
var enet_status:String = "状态：连接中"
func pipline_start():
	if server == "":
		$UDP.create.emit(1) # 创建UDP服务器
		enet_status_changed.emit(enet_status)
	else:
		$Enet.create.emit(server) # 创建Enet客户端连接到服务器

func _ready() -> void:
	pipline_start()

func _on_button_pressed() -> void:
	$UDP/has_broadcast_timer.stop()
	$UDP/has_broadcast_timer.timeout.emit()
	pass

func _on_enet_enet_created(status: String) -> void:
	enet_status = "状态:"+status
	enet_status_changed.emit(enet_status)

func _on_enet_peers_update(peers: Dictionary) -> void:
	peers_changed.emit(peers)


func _on_server_input_try_connect_server(server: String) -> void:
	$".".server = server
	pipline_start()
