extends Control

# 游戏的主界面

func _ready():
    randomize()
    _init_log_setting()


func _init_log_setting():
    pass
    #Log.get_logger(Log.LogModule.SERVER).disable()
    #Log.get_logger(Log.LogModule.CLIENT).disable()
    Log.get_logger(Log.LogModule.SCENE).disable()
    Log.get_logger(Log.LogModule.CONN).disable()


func _on_start_game():
    SceneMgr.goto_scene(SceneMgr.LOBBY_SCENE)


func _on_edit_character_info():
    SceneMgr.goto_scene(SceneMgr.PLAYER_SCENE)


func _on_exit_game():
    get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
