extends Control


# 玩家列表


const PlayerInfo: PackedScene = preload("res://ui/player/player_info.tscn")


func init():
    var order_info = _get_client().order_info
    var orders = order_info.order_to_name.keys()
    orders.sort()
    for order in orders:
        var item = PlayerInfo.instance()
        item.init(order, order_info.order_to_name[order], _get_client().setup_info.catan_size)
        $PlayerList.add_child(item)


func _get_client():
    return PlayingNet.get_client()