extends Control

# 游戏的主界面


# TODO: 支持取消建筑
# TODO: 支持特殊建筑阶段


func _on_start_game():
    SceneMgr.goto_scene(SceneMgr.LOBBY_SCENE)


func _on_edit_character_info():
    SceneMgr.goto_scene(SceneMgr.PLAYER_SCENE)


func _on_edit_setting():
    SceneMgr.goto_scene(SceneMgr.SETTING_SCENE)


func _on_exit_game():
    get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_open_editor():
    SceneMgr.goto_scene(SceneMgr.EDITOR_SCENE)
