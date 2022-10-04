extends PopupDialog


# 玩家交易发起者弹窗

const TradeTag: PackedScene = preload("res://ui/game/trade/trade_tag.tscn")

onready var _btn_group: ButtonGroup = ButtonGroup.new()


func _ready():
    _init_signal()


func _init_signal():
    _get_mgr().connect("trade_price_received", self, "_on_trade_price_received")


func _on_trade_price_received(trade_info: Protocol.TradeInfo):
    var tag = TradeTag.instance()
    $HBox/PlayerBg/Players.add_child(tag)
    tag.init(trade_info, _btn_group)
    tag.connect("tag_switched", self, "_on_tag_switched")


func _on_tag_switched(trade_info: Protocol.TradeInfo):
    $HBox/TradePanel.init_with_trade_info(trade_info)


func _on_trade_canceled(trade_info: Protocol.TradeInfo):
    queue_free()


func _on_trade_confirmed(trade_info: Protocol.TradeInfo):
    _get_client().request_trade(trade_info)
    queue_free()


func _on_trade_negotiated(trade_info: Protocol.TradeInfo):
    for child in $HBox/PlayerBg/Players.get_children():
        child.queue_free()
    $HBox/TradePanel.reset_name()
    _get_mgr().broadcast_trade_price(trade_info)


func _get_client():
    return PlayingNet.get_client()


func _get_mgr():
    return _get_client().trade_mgr


func _get_name():
    return _get_client().get_name()
