extends Node
var clipboard:String 
signal clipboard_updated(clip:String) # 本地的剪贴板更新(因为远程的会更新本地的）
signal clipboard_rpc(clip:String) # 调用rpc

func _ready() -> void:
	clipboard = DisplayServer.clipboard_get() # 初始化剪贴板
	
func _on_clipboard_update_timer_timeout() -> void:
	var clip = DisplayServer.clipboard_get()
	if not clip == clipboard and not clip == "":
		clipboard = clip 
		clipboard_updated.emit(clip)
		clipboard_rpc.emit(clipboard)
		
