extends Node


# 游戏中的网络协议


func get_client():
    return get_tree().get_nodes_in_group(Data.CLIENT)[0]


func get_server():
    return get_tree().get_nodes_in_group(Data.SERVER)[0]


# C2S


# 客户端准备就绪
master func client_ready(player_name: String):
    print(get_server(), player_name)


# S2C