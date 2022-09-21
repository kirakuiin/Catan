extends Control


# 世界ui覆盖层

func init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo):
    $PlayerInfos.init(order, setup.catan_size)
    $GameInfos.init()
    $Dice.init()


func _on_button_down():
    SceneMgr.close_pop_scene()