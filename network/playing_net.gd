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
master func place_settlement_done(player_name: String, pos: Vector3):
    get_server().add_settlement(player_name, pos)
    get_server().change_player_state(player_name, NetDefines.PlayerState.DONE)


# 客户端放置道路结束
master func place_road_done(player_name: String, road_data):
    get_server().add_road(player_name, Protocol.deserialize(road_data))
    get_server().change_player_state(player_name, NetDefines.PlayerState.DONE)


# 客户端让过
master func pass_turn(player_name: String):
    get_server().change_player_state(player_name, NetDefines.PlayerState.PASS)


# S2C

# 通知客户端放置道路
remotesync func place_road(is_setup):
    get_client().place_road(is_setup)


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


# 通知客户端修改指定玩家建筑信息
remotesync func change_building_info(player_name: String, data):
    get_client().change_building_info(player_name, Protocol.deserialize(data))


# 通知客户端修改指定玩家分数信息
remotesync func change_score_info(player_name: String, data):
    get_client().change_score_info(player_name, Protocol.deserialize(data))


# 通知客户端更新骰子
remotesync func change_dice(info: Array):
    get_client().change_dice(info)


# 通知客户端更新强盗位置
remotesync func change_robber_pos(pos: Vector3):
    get_client().change_robber_pos(pos)


# 通知客户端自由行动
remotesync func into_free_action():
    get_client().into_free_action()