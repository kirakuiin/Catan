extends Node


# 游戏中的网络协议


func get_client():
    return get_tree().get_nodes_in_group(NetDefines.CLIENT_NAME)[0]


func get_server():
    return get_tree().get_nodes_in_group(NetDefines.SERVER_NAME)[0]


# C2S


# 客户端准备就绪
master func client_ready(player_name: String):
    get_server().client_ready(player_name)


# 客户端放置定居点结束
master func place_settlement_done(player_name: String):
    get_server().change_player_state(player_name, NetDefines.PlayerOpState.DONE)


# 客户端放置道路结束
master func place_road_done(player_name: String):
    get_server().change_player_state(player_name, NetDefines.PlayerOpState.DONE)


# 客户端让过
master func pass_turn(player_name: String):
    get_server().change_player_state(player_name, NetDefines.PlayerOpState.PASS)


# S2C

# 通知客户端放置道路
remotesync func place_road():
    get_client().place_road()


# 通知客户端放置定居点
remotesync func place_settlement():
    get_client().place_settlement()


# 通知客户端辅助信息
remotesync func change_assist_info(data):
    get_client().change_assist_info(Protocol.deserialize(data))


# 通知客户端初始化建筑信息
remotesync func init_building_info(data):
    get_client().init_building_info(Protocol.deserialize(data))


# 通知客户端初始化分数信息
remotesync func init_score_info(data):
    get_client().init_score_info(Protocol.deserialize(data))