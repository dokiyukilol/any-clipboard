extends Node
signal create(address:String)
signal enet_created(status:String)
signal peers_update(peers:Dictionary)
var ENET_PORT = 25534 
var localhost = ""
var local_uid:int
var MAX_CLIENTS = 16
var peers = {}
# 创建Enet对等体
func _on_create(address:String): 
	var peer:ENetMultiplayerPeer = get_node("..").peer
	peer = ENetMultiplayerPeer.new()
	if address == "":
		peer.create_server(ENET_PORT,MAX_CLIENTS)
		$"../../Back/Label".text +="server."
		enet_created.emit("server")
	else:
		peer.create_client(address,ENET_PORT)
		$"../../Back/Label".text +="client."
		enet_created.emit("client.")
		
	multiplayer.multiplayer_peer = peer
		
	local_uid = multiplayer.multiplayer_peer.get_unique_id()
	peers[local_uid] = localhost  # 创建EnetPeer时，说明已经作为UDP服务器：已经获取localhost
	
func _ready() -> void:
	create.connect(_on_create)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	
	multiplayer.connection_failed.connect(_on_connect_faild)
	multiplayer.server_disconnected.connect(_on_serverdisconnected)
	$"../UDP".had_host.connect(_on_had_host)
	
func restart_enet(): # 当作为Enet客户端连接失败、或突然连接失败
	$"../../Back/Label".text = ""
	enet_created.emit("重试中")
	var peer:ENetMultiplayerPeer = get_node("..").peer
	peers.clear()
	if not peer == null:
		peer.close()
		peer = null
	multiplayer.multiplayer_peer = null
	$"../UDP".create.emit(1)
	peers_update.emit(peers)
	
func _on_connect_faild():
	restart_enet()
	
func _on_serverdisconnected():
	restart_enet()
	
func _on_peer_connected(id:int):
	set_peer_ip.rpc(local_uid,localhost) # 广播自己的ip
	
func _on_peer_disconnected(id:int):
	peers.erase(id)
	peers_update.emit(peers)
	
func _on_had_host(ip:String):
	localhost = ip

# 客户端连接上后调用所有对等体 设置peers
@rpc("any_peer","call_local")
func set_peer_ip(id:int,ip:String):
	peers[id] = ip
	peers_update.emit(peers)
	
@rpc("any_peer","call_local")
func set_clipboard(clip:String):
	#$"../../Back/MarginContainer/HSplitContainer/VBoxContainer2/Status".text = clip
	DisplayServer.clipboard_set(clip)


func _on_clip_clipboard_rpc(clip: String) -> void:
	if len(peers) >= 2:
		set_clipboard.rpc(clip)
