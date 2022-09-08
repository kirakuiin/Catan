extends Node


const MAIN_SCENE: String = "res://main.tscn"
const LOBBY_SCENE: String = "res://ui/lobby/game_lobby.tscn"
const PREPARE_SCENE: String = "res://ui/lobby/prepare_lobby.tscn"
const PLAYER_SCENE: String = "res://ui/info/player_info.tscn"


# 切换场景
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	var current_scene = get_tree().current_scene
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
