extends Control


# 玩家列表


const PlayerInfo: PackedScene = preload("res://ui/player/player_info.tscn")


func init(order_info: Protocol.PlayerOrderInfo, catan_size: int):
    var orders = order_info.order_to_name.keys()
    orders.sort()
    for order in orders:
        var item = PlayerInfo.instance()
        item.init(order, order_info.order_to_name[order], catan_size)
        $PlayerList.add_child(item)