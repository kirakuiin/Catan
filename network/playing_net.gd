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


# 客户端请求重连
master func client_reconnect(player_name: String):
    get_server().client_reconnect(player_name)


# 请求放置定居点
master func request_place_settlement(player_name: String):
    get_server().request_place_settlement(player_name)


# 请求放置道路
master func request_place_road(player_name: String):
    get_server().request_place_road(player_name)


# 请求升级城市
master func request_upgrade_city(player_name: String):
    get_server().request_upgrade_city(player_name)


# 请求购买卡牌
master func request_buy_dev_card(player_name: String):
    get_server().request_buy_dev_card(player_name)


# 请求打出卡牌
master func request_play_card(player_name: String, dev_type: int):
    get_server().request_play_card(player_name, dev_type)


# 客户端发起交易
master func request_trade(trade_data):
    get_server().request_trade(Protocol.deserialize(trade_data))


# 客户端放置定居点结束
master func place_settlement_done(player_name: String, pos: Vector3):
    get_server().add_settlement(player_name, pos)


# 客户端放置道路结束
master func place_road_done(player_name: String, road_data, is_need_res):
    get_server().add_road(player_name, Protocol.deserialize(road_data), is_need_res)


# 客户端放置道路结束
master func upgrade_city_done(player_name: String, pos: Vector3):
    get_server().upgrade_city(player_name, pos)


# 客户端让过
master func pass_turn(player_name: String):
    get_server().change_player_net_state(player_name, NetDefines.PlayerNetState.PASS)


# 丢弃完成
master func discard_done(player_name: String, discard_data):
    get_server().discard_done(player_name, Protocol.deserialize(discard_data))


# 移动强盗完毕
master func move_robber_done(player_name: String, pos: Vector3):
    get_server().move_robber_done(player_name, pos)


# 抢夺玩家完毕
master func rob_player_done(player_name: String, robbed_player: String):
    get_server().rob_player_done(player_name, robbed_player)


# 选择资源完毕
master func choose_res_done(player_name: String, result: Dictionary):
    get_server().choose_res_done(player_name, result)


# 选择垄断资源完毕
master func choose_mono_type_done(player_name: String, result: int):
    get_server().choose_mono_type_done(player_name, result)



master func ready_to_exit(player_name: String):
    get_server().ready_to_exit(player_name)


# 玩家取消操作
master func cancel_op(player_name: String):
    get_server().cancel_op(player_name)


# S2C

# 通知客户端放置道路
remotesync func place_road(type):
    get_client().place_road(type)


# 通知客户端放置定居点
remotesync func place_settlement(type):
    get_client().place_settlement(type)


# 通知客户端放置定居点
remotesync func upgrade_city():
    get_client().upgrade_city()


# 通知客户端辅助信息
remotesync func change_assist_info(data):
    get_client().change_assist_info(Protocol.deserialize(data))


# 通知客户端银行信息
remotesync func change_bank_info(data):
    get_client().change_bank_info(Protocol.deserialize(data))


# 通知客户端初始化建筑信息
remotesync func init_building_info(data):
    get_client().init_building_info(Protocol.deserialize(data))


# 通知客户端初始化卡牌信息
remotesync func init_card_info(data):
    get_client().init_card_info(Protocol.deserialize(data))


# 通知客户端初始化个人信息
remotesync func init_personal_info(data):
    get_client().init_personal_info(Protocol.deserialize(data))


# 通知客户端初始化揭示信息
remotesync func init_revealed_info(data: Array):
    get_client().init_revealed_info(data)


# 通知客户端修改指定玩家建筑信息
remotesync func change_building_info(player_name: String, data):
    get_client().change_building_info(player_name, Protocol.deserialize(data))


# 通知客户端修改指定玩家卡牌信息
remotesync func change_card_info(player_name: String, data):
    get_client().change_card_info(player_name, Protocol.deserialize(data))


# 通知客户端个人信息
remotesync func change_personal_info(player_name: String, data):
    get_client().change_personal_info(player_name, Protocol.deserialize(data))


# 通知客户端揭示信息
remotesync func change_revealed_info(pos: Vector3):
    get_client().change_revealed_info(pos)


# 通知客户端更新骰子
remotesync func change_dice(info: Array):
    get_client().change_dice(info)


# 通知客户端更新强盗位置
remotesync func change_robber_pos(pos: Vector3):
    get_client().change_robber_pos(pos)


# 通知客户端自由行动
remotesync func into_free_action():
    get_client().into_free_action()


# 通知客户端丢弃资源
remotesync func discard_resource():
    get_client().discard_resource()


# 通知客户端丢弃资源
remotesync func move_robber():
    get_client().move_robber()


# 通知客户端抢劫玩家
remotesync func rob_player():
    get_client().rob_player()


# 通知客户端特殊出卡
remotesync func special_play():
    get_client().special_play()


# 通知客户端进入特殊阶段
remotesync func into_special_building():
    get_client().into_special_building()


# 通知客户端选择获得资源
remotesync func choose_res():
    get_client().choose_res()


# 通知客户端选择垄断类型
remotesync func choose_mono_type():
    get_client().choose_mono_type()


# 向客户端发送通知
remotesync func send_notification(data):
    get_client().receive_notification(Protocol.deserialize(data))


# 通知客户端打开分数结算界面
remotesync func show_score_panel(data):
    get_client().show_score_panel(Protocol.deserialize(data))


# 通知客户端退出到准备界面
remotesync func exit_to_prepare():
    get_client().exit_to_prepare()


# 通知客户端发送重连数据结束
remotesync func send_reconnect_data_done():
    get_client().reconnect_done()