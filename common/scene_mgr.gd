extends Node


const MAIN_SCENE: String = "res://main.tscn"
const LOBBY_SCENE: String = "res://ui/lobby/game_lobby.tscn"
const PREPARE_SCENE: String = "res://ui/lobby/prepare_lobby.tscn"
const PLAYER_SCENE: String = "res://ui/info/player_info_setting.tscn"
const WORLD_SCENE: String = "res://ui/game/world.tscn"


var _scene_stack: Array = []


func _ready():
	_scene_stack.append(get_cur_scene())


# 切换场景
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)
	Log.logd("打开场景[%s]" % path)


func _deferred_goto_scene(path):
	_close_all_pop()
	var s = ResourceLoader.load(path)
	var current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	_scene_stack.append(current_scene)


func _close_all_pop():
	for scene in _scene_stack:
		scene.free()
	_scene_stack.clear()


# 浮出场景
func pop_scene(path):
	var current_scene = get_cur_scene()
	current_scene.hide()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	_scene_stack.append(current_scene)
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	Log.logd("场景堆栈[%s]" % String(_scene_stack))
	return current_scene


# 关闭场景
func close_pop_scene():
	call_deferred("_deferred_close_pop_scene")


func _deferred_close_pop_scene():
	if len(_scene_stack) < 2:
		return
	var current_scene = get_cur_scene()
	current_scene.free()
	_scene_stack.pop_back()
	current_scene = _scene_stack.back()
	current_scene.show()
	get_tree().set_current_scene(current_scene)
	Log.logd("场景堆栈[%s]" % String(_scene_stack))


# 返回当前场景
func get_cur_scene():
	return get_tree().current_scene


# 返回指定场景
func get_scene(cls):
	for scene in _scene_stack:
		if scene is cls:
			return scene
	return null
