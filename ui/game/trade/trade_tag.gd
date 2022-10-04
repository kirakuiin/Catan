extends Control


# 交易标签

signal tag_switched(trade_info)  # 标签切换

var _trade_info: Protocol.TradeInfo


# 初始化标签
func init(trade_info: Protocol.TradeInfo, btn_group: ButtonGroup):
    _trade_info = trade_info
    $Button.group = btn_group
    $Color.color = _get_client().get_color(trade_info.from_player)
    match trade_info.trade_state:
        NetDefines.TradeState.AGREE:
            $Image.texture = load("res://assets/images/tick.png")
        NetDefines.TradeState.NEGOTIATE:
            $Image.texture = load("res://assets/icons/trade.png")
        NetDefines.TradeState.REFUSE:
            $Image.texture = load("res://assets/images/cross.png")
            $Button.disabled = true


func _get_client():
    return PlayingNet.get_client()


func _on_switch_tag(is_toggle: bool):
    if is_toggle:
        emit_signal("tag_switched", _trade_info)
