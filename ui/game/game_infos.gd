extends Control


# 游戏中提示信息


func init():
    _init_signal()


func _init_signal():
    _get_client().connect("assist_info_changed", self, "_on_assist_info_changed")


func _get_client():
    return PlayingNet.get_client()


func _on_assist_info_changed(assist_info: Protocol.AssistInfo):
    _show_player_turn(assist_info.player_turn_name)
    _show_turn_info(assist_info.turn_num)


func _show_player_turn(player_name: String):
    var order = _get_client().order_info.get_order(player_name)
    var color = Data.ORDER_DATA[order]
    $PlayerTurn.add_color_override("font_color", color)
    $PlayerTurn.text = "玩家[%s]行动..." % player_name


func _show_turn_info(turn_num: int):
    if turn_num == 0:
        $Turn.text = "布置阶段"
    else:
        $Turn.text = "回合[%d]" % turn_num