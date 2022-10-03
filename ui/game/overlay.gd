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
    # TODO: 测试使用, 测试完毕删除
    if not GameServer.is_server():
        $Button.hide()


func _on_button_down():
    SceneMgr.close_pop_scene()