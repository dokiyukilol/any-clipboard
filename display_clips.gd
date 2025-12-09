extends Button
var new_clipboard:String = ""

func _on_clip_clipboard_updated(clip: String) -> void:
	if new_clipboard == clip:
		new_clipboard = ""
	else:
		new_clipboard = clip
	
	if $"..".is_display_clip:
		try_update_edit()
		
func try_update_edit():
	if new_clipboard == "":
		$"../../VBoxContainer2/MarginContainer/TextEdit".text = "未接收到剪贴板"
	else:
		$"../../VBoxContainer2/MarginContainer/TextEdit".text = new_clipboard

func _on_pressed() -> void:
	$"..".is_display_clip = true
	try_update_edit()
