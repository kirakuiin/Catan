extends PopupDialog


# 分数结算弹窗

const DiceItem: PackedScene = preload("res://ui/game/score/dice_item.tscn")


# 初始化窗口
func init(stat_info: Protocol.StatInfo):
    $WinnerCon/Name.text = stat_info.winner_name
    $WinnerCon/Name.modulate = Data.ORDER_DATA[_get_client().order_info.get_order(stat_info.winner_name)]
    $VCon/TurnCon/Num.text = str(stat_info.turn_num)
    for item in _generate_dice_item(stat_info.dice_info):
        $VCon/DiceCon/DiceScroll/DiceItems.add_child(item)


func _generate_dice_item(dice_info: Dictionary) -> Array:
    var result = []
    var dice_array = StdLib.dict_to_array(dice_info)
    dice_array.sort_custom(self, "_custom_sort")
    for p_n in dice_array:
        var item = DiceItem.instance()
        item.set_data(p_n[0], p_n[1])
        result.append(item)
    return result

func _custom_sort(a: Array, b: Array):
    if a[1] == b[1]:
        return a[0] < b[0]
    else:
        return a[1] > b[1]


func _on_confirm_exit():
    $Confirm.text = "等待其他玩家..."
    $Confirm.disabled = true
    _get_client().ready_to_exit()


func _get_client():
    return PlayingNet.get_client()