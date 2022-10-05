extends Control

# 玩家准备桌面

signal all_player_ready(is_ready)


const PlayerIcon: Script = preload("res://ui/player/player_icon.gd")


var _order_info: Protocol.PlayerOrderInfo


func _init():
    _order_info = Protocol.PlayerOrderInfo.new()


func _ready():
    PlayerInfoMgr.connect("player_removed", self, "_on_player_removed")
    _init_seat()


# 返回顺序信息
func get_order_info():
    return Protocol.copy(_order_info)


func _init_seat():
    if not GameServer.is_server():
        rpc("send_order_info", GameServer.get_peer_id())


master func send_order_info(peer_id: int):
    var net_data = Protocol.serialize(_order_info)
    rpc_id(peer_id, "recv_order_info", net_data)


puppet func recv_order_info(net_data):
    _order_info = Protocol.deserialize(net_data) as Protocol.PlayerOrderInfo
    _reset_seat()


func _on_seat1(order: int):
    _seat_by_order(order)


func _on_seat2(order: int):
    _seat_by_order(order)


func _on_seat3(order: int):
    _seat_by_order(order)


func _on_seat4(order: int):
    _seat_by_order(order)


func _on_seat5(order: int):
    _seat_by_order(order)


func _on_seat6(order: int):
    _seat_by_order(order)


func _seat_by_order(order: int):
    _adjust_order(order)
    rpc("sync_order_info", Protocol.serialize(_order_info))


func _adjust_order(order: int):
    var player_name = PlayerInfoMgr.get_self_info().player_name
    var src_order = _order_info.get_order(player_name)
    var des_name = _order_info.get_name(order)
    if src_order > 0:
        _order_info.order_to_name.erase(src_order)
        if des_name:
            _order_info.order_to_name[src_order] = des_name
    _order_info.order_to_name[order] = player_name


remotesync func sync_order_info(net_data):
    _order_info = Protocol.deserialize(net_data) as Protocol.PlayerOrderInfo
    _reset_seat()
    if len(PlayerInfoMgr.get_all_info()) == len(_order_info.order_to_name):
        emit_signal("all_player_ready", true)
    else:
        emit_signal("all_player_ready", false)


func _reset_seat():
    var info = _order_info.order_to_name
    for order in range(1, Data.CatanSize.BIG+1):
        var icon = _get_icon_by_order(order)
        if order in info:
            icon.init(PlayerInfoMgr.get_info(info[order]))
        else:
            icon.clear()


func _get_icon_by_order(order: int):
    return get_node("Seat%d" % order) as PlayerIcon


func _on_player_removed(player_info: Protocol.PlayerInfo):
    var order = _order_info.get_order(player_info.player_name)
    if _order_info.order_to_name.erase(order):
        _reset_seat()