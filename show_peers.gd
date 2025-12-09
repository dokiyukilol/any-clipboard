extends Label

func _on_timer_timeout() -> void:
	text = ""
	for k in $"../../DevFind/Enet".peers:
		text += "%s"%k + ":"+$"../../DevFind/Enet".peers	[k]+"\n"
