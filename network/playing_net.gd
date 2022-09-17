extends Node


# 游戏中的网络协议


func get_client():
    return get_tree().get_nodes_in_group(NetDefines.CLIENT_NAME)[0]


func get_server():
    return get_tree().get_nodes_in_group(NetDefines.SERVER_NAME)[0]


# C2S


# 客户端准备就绪
master func client_ready(player_name: String):
    get_server().player_state_change(player_name, NetDefines.PlayerOpState.READY)


# 客户端放置定居点结束
master func place_settlement_done(player_name: String):
    get_server().player_state_change(player_name, NetDefines.PlayerOpState.PLACE_SETTLEMENT_DONE)


# 客户端放置道路结束
master func place_road_done(player_name: String):
    get_server().player_state_change(player_name, NetDefines.PlayerOpState.PLACE_ROAD_DONE)


# S2C

# 通知客户端放置道路
remotesync func place_road():
    get_client().place_road()


# 通知客户端放置定居点
remotesync func place_settlement():
    get_client().place_settlement()