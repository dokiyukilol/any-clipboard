extends Control

var main = preload("res://main.tscn")
func _ready() -> void:
	$AnimationPlayer.play("scale_rotation")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	get_tree().change_scene_to_packed(main)
	$".".visible = false
