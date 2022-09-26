extends Control


# 世界ui覆盖层

func init():
    $PlayerInfos.init()
    $GameInfos.init()
    $Dice.init()
    $Operation.init()
    $ResZone.init()
    $DevZone.init()


func _on_button_down():
    SceneMgr.close_pop_scene()