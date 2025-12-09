extends Node
signal create(id:int) # UDP创建信号
signal had_host(ip:String) # 发送需要host的节点

var UDP_PORT = 25533 # UDP服务器端口
var UDP_RECV_INTERVAL = 0.7 + randf_range(0, 2) # 确认局域网存在广播的时间
var UDP_SEND_INTERVAL = 0.5 # 作为Enet服务器 UDP客户端 广播自身的间隔
var has_udpbroadcast:bool # 局域网内是否存在广播
var is_udpbroadcast:bool # 是否进行广播
var host:String # 广播的内容，也可能作为UDP客户端的ip（bind）
var udp_server_peer:PacketPeerUDP
var udp_client_peer:PacketPeerUDP

var udpbroadcast_msg:String #广播的消息
var udpbroadcast_msgb:PackedByteArray # 广播的消息

var enet_server:String # 局域网中广播的ip，将于procee监听到udp报后处理得到

# 获取本机IP 以尝试作为局域网Enet服务器
func initial_udpbroadcastmsg() -> void:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192."):
			host = ip
			had_host.emit(ip)
			break
	assert(not host == null,"找不到本机ip")
	udpbroadcast_msg = $"../Mid".pad_prefix(host)
	udpbroadcast_msgb = $"../Mid".encode(udpbroadcast_msg)

func initial_start_udp() ->void:
		has_udpbroadcast = false
		is_udpbroadcast = false
		if udp_server_peer is PacketPeerUDP:
			udp_server_peer.close()
		if udp_client_peer is PacketPeerUDP:
			udp_client_peer.close()
		udp_server_peer = null
		udp_client_peer = null
		enet_server = ""
		$has_broadcast_timer.start(UDP_RECV_INTERVAL) # 这个启动时间主要决定发现局域网服务器

func _ready() -> void:
	initial_udpbroadcastmsg()
	
	create.connect(_on_create)
# 创建UDP客户端/服务器
func _on_create(id:int):
	if id == 1:
		initial_start_udp()
		if udp_server_peer == null:
			udp_server_peer = PacketPeerUDP.new()
			udp_server_peer.set_broadcast_enabled(true)
			udp_server_peer.bind(UDP_PORT) # 作为UDP服务器 bind监听地址
	else:
		if udp_client_peer == null:
			udp_client_peer = PacketPeerUDP.new()
			udp_client_peer.set_broadcast_enabled(true)
		udp_client_peer.bind(0,host)
		udp_client_peer.set_dest_address("255.255.255.255", UDP_PORT) 
		# 作为UDP客户端，发送接口为本机随机端口，发送目标广播
		
# 尝试监听UDP广播
func _process(delta: float) -> void:
	var try2beEnetS = not has_udpbroadcast# 没有发现UDP广播
	var udpSopen = not udp_server_peer == null# UDP服务器已经开启
	var isntEnetS = is_udpbroadcast == false# 没有在UDP广播（在UDP广播说明已经作为了Enet服务器）
	if udpSopen and isntEnetS and try2beEnetS:
		# 接收到了UDP广播
		
		if udp_server_peer.get_available_packet_count() > 0 :
			var array_bytes:PackedByteArray = udp_server_peer.get_packet()
			var udp_decry:String = $"../Mid".decode(array_bytes)
			# 解密AES 并去除填充16 确认前缀正确
			if $"../Mid".check_prefix(udp_decry):
				has_udpbroadcast = true # 确认有服务器在广播
				var removed_prefix_udp = $"../Mid".remove_prefix(udp_decry)
				enet_server = removed_prefix_udp
				$has_broadcast_timer.stop()
				$has_broadcast_timer.timeout.emit()
				
# 尝试确认局域网内UDP广播存在性超时
func _on_has_broadcast_timer_timeout() -> void:
	if has_udpbroadcast == false: # 不存在广播 作为Enet服务器 发送UDP
		is_udpbroadcast = true
		$".".create.emit(123)# 创建UDP客户端  
		$udp_broadcast_timer.start(UDP_SEND_INTERVAL)# 准备UDP广播
		$"../Enet".create.emit("") # 创建Enet服务器
	elif has_udpbroadcast == true: # 存在广播
		is_udpbroadcast = false  # 不进行广播
		$"../Enet".create.emit(enet_server) # 连接广播的服务器
	# 时间到了没发现广播 就开始udp广播 .或者连接Enet服务器

var udp_broadcast_times = 0
func _on_udp_broadcast_timer_timeout() -> void:
	if udp_broadcast_times <= 120 and udp_broadcast_times >= 0:
		udp_broadcast_times += 1
	elif not udp_broadcast_times == -1:
		udp_broadcast_times = -1
		UDP_SEND_INTERVAL = 1
		
		$udp_broadcast_timer.start(UDP_SEND_INTERVAL)
	if not udp_client_peer == null: # 创建UDP客户端和启动UDP广播都是 信号 异步使得可能为null
		udp_client_peer.put_packet(udpbroadcast_msgb)
