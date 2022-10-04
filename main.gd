extends Control

# 游戏的主界面

func _ready():
    randomize()


func _on_start_game():
    SceneMgr.goto_scene(SceneMgr.LOBBY_SCENE)


func _on_edit_character_info():
    SceneMgr.goto_scene(SceneMgr.PLAYER_SCENE)


func _on_edit_setting():
    SceneMgr.goto_scene(SceneMgr.SETTING_SCENE)


func _on_exit_game():
    get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
