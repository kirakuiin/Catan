extends PopupDialog

# 玩家交易接受者弹窗


# 初始化弹窗
func init(trade_info: Protocol.TradeInfo):
    $TradePanel.init_with_trade_info(trade_info)


func _on_trade_canceled(trade_info: Protocol.TradeInfo):
    trade_info.trade_state = NetDefines.TradeState.REFUSE
    _get_mgr().response_trade_price(trade_info)
    queue_free()


func _on_trade_confirmed(trade_info: Protocol.TradeInfo):
    trade_info.trade_state = NetDefines.TradeState.AGREE
    _get_mgr().response_trade_price(trade_info)
    queue_free()


func _on_trade_negotiated(trade_info: Protocol.TradeInfo):
    trade_info.trade_state = NetDefines.TradeState.NEGOTIATE
    _get_mgr().response_trade_price(trade_info)
    queue_free()


func _get_client():
    return PlayingNet.get_client()


func _get_mgr():
    return _get_client().trade_mgr


func _get_name():
    return _get_client().get_name()