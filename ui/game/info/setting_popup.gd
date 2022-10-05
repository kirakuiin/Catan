extends PopupDialog


# 游戏内设置弹窗

func _on_quit_to_lobby():
    SceneMgr.goto_scene(SceneMgr.LOBBY_SCENE)
    GameServer.close_game()