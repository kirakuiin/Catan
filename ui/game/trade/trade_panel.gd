extends Control

# 交易面板

signal trade_confirmed(trade_info)  # 确认
signal trade_negotiated(trade_info)  # 协商
signal trade_canceled()  # 取消


var _trade_info: Protocol.TradeInfo


func _init():
    _trade_info = Protocol.TradeInfo.new(_get_name())


# 重置名称
func reset_name():
    $Title/TradeName.text = ""


# 使用交易数据初始化
func init_with_trade_info(trade_info: Protocol.TradeInfo):
    _trade_info = Protocol.TradeInfo.new()
    _trade_info.load_var(trade_info.to_var())
    $Title/TradeName.text = trade_info.from_player
    $Title/TradeName.modulate = _get_client().get_color(trade_info.from_player)
    _trade_info.flip()
    _init_item()
    _init_ui()

func _init_item():
    for item in $ItemCon.get_children():
        item.set_item(_trade_info)

func _init_ui():
    _to_confirm_btn()
    _set_balance()
    _set_btn_state()


func _on_trade_changed(res_type: int, num: int, unit: int):
    _trade_info.pay_info.erase(res_type)
    _trade_info.get_info.erase(res_type)
    if num > 0:
        _trade_info.get_info[res_type] = num
    elif num < 0:
        _trade_info.pay_info[res_type] = abs(num)
    _set_balance()
    _set_btn_state()
    _to_trade_btn()


func _to_trade_btn():
    $Negotiate.show()
    $Confirm.hide()


func _to_confirm_btn():
    $Negotiate.hide()
    $Confirm.show()


func _set_btn_state():
    var is_disable = false
    for res_type in _trade_info.pay_info:
        if StdLib.dict_get(_get_client().player_cards[_get_name()].res_cards, res_type, 0) < _trade_info.pay_info[res_type]:
            is_disable = true
    var get_and_pay = _get_and_pay()
    if not (get_and_pay[0] and get_and_pay[1]):
        is_disable = true
    $Negotiate.disabled = is_disable
    $Confirm.disabled = is_disable


func _get_and_pay() -> Array:
    var has_get = false
    var has_pay = false
    has_get = StdLib.sum(_trade_info.get_info.values()) > 0
    has_pay = StdLib.sum(_trade_info.pay_info.values()) > 0
    return [has_get, has_pay]

func _set_balance():
    var get_and_pay = _get_and_pay()
    var has_get = get_and_pay[0]
    var has_pay = get_and_pay[1]
    if (has_get and has_pay) or (not has_get and not has_pay):
        $Balance/Pole.rect_rotation = 0
    else:
        $Balance/Pole.rect_rotation = -30 if has_get else 30


func _on_cancel():
    emit_signal("trade_canceled")


func _on_confirm():
    $Confirm.disabled = true
    emit_signal("trade_confirmed", _trade_info)
    

func _on_negotiate():
    $Negotiate.disabled = true
    emit_signal("trade_negotiated", _trade_info)


func _get_client():
    return PlayingNet.get_client()


func _get_name():
    return _get_client().get_name()
