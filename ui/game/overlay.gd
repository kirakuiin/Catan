extends Control


# 世界ui覆盖层

func init():
    $PlayerInfos.init()
    $GameInfos.init()
    $BankInfo.init()
    $Dice.init()
    $Operation.init()
    $ResZone.init()
    $DevZone.init()
    $AudioPlayer.init()
    $Option.init()
    # TODO: 测试使用, 测试完毕删除
    if not GameServer.is_server():
        $QuitBtn.hide()


func _on_button_down():
    SceneMgr.close_pop_scene()


func _on_open_setting():
    SceneMgr.show_prompt("未实现!")