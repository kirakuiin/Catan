extends Control


# 世界ui覆盖层

signal show_setting  # 展示设置界面


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


func _on_open_setting():
    emit_signal("show_setting")