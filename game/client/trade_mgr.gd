extends Node


# 交易管理器

signal trade_price_received(trade_info)  # 收到交易报价


onready var _logger: Log.Logger = Log.get_logger(Log.LogModule.TRADE)


# 发起交易报价
func broadcast_trade_price(trade_info: Protocol.TradeInfo):
    _logger.logd("玩家[%s]发起交易报价 %s" % [trade_info.from_player, trade_info])
    for player_info in PlayerInfoMgr.get_all_info():
        if player_info != PlayerInfoMgr.get_self_info():
            trade_info.to_player = player_info.player_name
            rpc_id(player_info.peer_id, "send_trade_price", Protocol.serialize(trade_info))


# 回复交易报价
func response_trade_price(trade_info: Protocol.TradeInfo):
    _logger.logd("玩家[%s]回复交易报价 %s" % [trade_info.from_player, trade_info])
    var peer_id = PlayerInfoMgr.get_peer(trade_info.to_player)
    rpc_id(peer_id, "send_trade_price", Protocol.serialize(trade_info))


# 收到报价
func receive_trade_price(trade_info: Protocol.TradeInfo):
    _logger.logd("玩家[%s]收到来自[%s]的交易报价: %s" % [trade_info.to_player, trade_info.from_player, trade_info])
    emit_signal("trade_price_received", trade_info)


# 发送交易报价
remote func send_trade_price(trade_data):
    var trade_info = Protocol.deserialize(trade_data)
    receive_trade_price(trade_info)