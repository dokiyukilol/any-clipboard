extends Label


func _on_dev_find_enet_status_changed(status: String) -> void:
	text = status
