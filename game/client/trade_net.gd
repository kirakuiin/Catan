extends Node


# 交易网络协议

func get_mgr():
    return get_parent().trade_mgr


# 发送交易报价
remote func send_trade_price(trade_data):
    var trade_info = Protocol.deserialize(trade_data)
    get_mgr().receive_trade_price(trade_info)