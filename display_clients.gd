extends Button
var peer_list = {}
var show_info = []
func _on_dev_find_peers_changed(peers: Dictionary) -> void:
	peer_list = peers
	show_info.clear()
	
func show_peers():
	show_info.clear()
	
	var line:String = ""
	if len(peer_list) <= 1:
		line = "error:未发现客户端/服务器"
		show_info.append(line)
	elif peer_list.has(1):
		line = "server:" + peer_list[1]
		show_info.append(line)
		for k in peer_list:
			if not k == 1:
				line = "client:" + peer_list[k]
				show_info.append(line)
	else:
		line = "error:unkown DisplayClients."
		show_info.append(line)
		
	
	$"../../VBoxContainer2/MarginContainer/TextEdit".text = ""
	for peer_info in show_info:
		$"../../VBoxContainer2/MarginContainer/TextEdit".text += peer_info + "\n"



func _on_pressed() -> void:
	$"..".is_display_clip = false
	show_peers()
