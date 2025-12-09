extends Button
signal try_connect_server(server:String)

func check_ip(ip:String) -> bool:
	var server_text:String = ip
	var check:bool = true
	if not server_text.find(".") == -1:
		var lastfound = server_text.find(".")
		for i in range(2):
			lastfound = server_text.find(".",lastfound)
			if lastfound == -1:
				check = false
				break
	else:
		check = false	
	var parts:Array = server_text.split(".")
	for ip_part in parts:
		for chr in ip_part:
			if not chr in "1234567890":
				check = false
				break
	
	if not check:
		$"../../VBoxContainer2/MarginContainer/TextEdit".text = "需要在此输入合法的服务器IP"
	else:
		$"../../VBoxContainer2/MarginContainer/TextEdit".text = "正在尝试连接到:"+server_text
		try_connect_server.emit(server_text)
	return check
		
func _on_pressed() -> void:
	$"..".is_display_clip = false
	check_ip($"../../VBoxContainer2/MarginContainer/TextEdit".text)
func _on_text_edit_text_changed() -> void:
	pass # Replace with function body.
