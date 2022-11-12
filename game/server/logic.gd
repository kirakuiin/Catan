extends Node


# 游戏中服务器

const State: Script = preload("res://game/server/state/state.gd")
const Dice: Script = preload("res://game/server/dice.gd")
const ResMgr: Script = preload("res://game/server/res_mgr.gd")
const CardMgr: Script = preload("res://game/server/card_mgr.gd")
const VPMgr: Script = preload("res://game/server/vp_mgr.gd")


var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo

var player_buildings: Dictionary
var player_cards: Dictionary
var player_personals: Dictionary
var assist_info: Protocol.AssistInfo
var bank_info: Protocol.BankInfo
var robber_pos: Vector3
var stat_info: Protocol.StatInfo
var revealed_info: StdLib.Set

var player_net_state: Dictionary
var player_op_state: Dictionary
var dice: Dice

var _server_state: HSM.StateMachine
var _res_mgr: ResMgr
var _vp_mgr: VPMgr
var _card_mgr: CardMgr
onready var _logger: Log.Logger = Log.get_logger(Log.LogModule.SERVER)


# 初始化服务器数据
func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map
    dice = Dice.new()


func _ready():
    _init_node_setup()
    _init_player_info()
    _init_robber()
    _init_state_machine()
    _init_player_state()
    _init_mgr()
    ConnState.to_playing(order_info.order_to_name.values())
    _logger.logi("游戏服务端启动...")


func _init_node_setup():
    name = NetDefines.SERVER_NAME
    add_to_group(NetDefines.SERVER_NAME)


func _init_player_info():
    player_buildings = {}
    player_cards = {}
    player_personals = {}
    revealed_info = StdLib.Set.new()
    assist_info = Protocol.AssistInfo.new()
    bank_info = Protocol.BankInfo.new(map_info.resource_data, StdLib.sum(map_info.card_data.values()))
    stat_info = Protocol.StatInfo.new(OS.get_unix_time())


func _init_robber():
    var canditate_pos = []
    for tile in map_info.tile_map.values():
        if tile.tile_type == Data.TileType.DESERT:
            canditate_pos.append(tile.cube_pos)
    if not canditate_pos:
        canditate_pos = [Vector3(0, 0, 0)]
    canditate_pos.shuffle()
    robber_pos = canditate_pos[0]


func _init_state_machine():
    _server_state = State.CatanStateMachine.new(self)


func _init_player_state():
    for name in order_info.order_to_name.values():
        player_net_state[name] = NetDefines.PlayerNetState.NOT_READY
    for name in order_info.order_to_name.values():
        player_op_state[name] = NetDefines.PlayerOpStruct.new()


func _init_mgr():
    _res_mgr = ResMgr.new(map_info, player_buildings, player_cards, setup_info, bank_info)
    _card_mgr = CardMgr.new(player_cards, player_personals, map_info, bank_info)
    _vp_mgr = VPMgr.new(setup_info, player_cards, player_buildings, player_personals, assist_info)


func _process(delta):
    var old_state = String(_server_state.get_states_path())
    var result = _server_state.update()
    var new_state = String(_server_state.get_states_path())
    if old_state != new_state:
        _logger.logd("状态改变%s->%s" % [old_state, new_state])
    _execute_result(result)
    

func _execute_result(result: HSM.UpdateResult):
    for action in result.actions:
        action.invoke()
    

# Public

# 重置玩家网络状态
func reset_player_net_state(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.READY)


# 重置玩家操作状态
func reset_player_op_state(player_name: String):
    change_player_op_state(player_name, NetDefines.PlayerOpState.NONE, [])


# 设置当前玩家回合名称
func set_cur_turn_name(player_name: String):
    assist_info.player_turn_name = player_name
    broadcast_assist_info()


# 设置回合阶段
func set_turn_phase(phase: String):
    _logger.logd("回合阶段[%s]" % phase)
    assist_info.turn_phase = phase
    broadcast_assist_info()


# 设置当前大回合数
func update_turn_num():
    assist_info.turn_num += 1
    broadcast_assist_info()


# 投掷骰子
func roll_dice():
    broadcast_dice_info(dice.roll())
    StdLib.num_dict_add(stat_info.dice_info, dice.get_last_num(), 1)


# 设置胜者
func set_stat_info():
    for player in player_personals:
        if player_personals[player].vic_point >= map_info.victory_point:
            stat_info.winner_name = player
            break
    stat_info.turn_num = assist_info.turn_num
    stat_info.total_time = OS.get_unix_time()-stat_info.total_time
    

# 分发资源
func dispatch_resource():
    _res_mgr.set_robber(robber_pos)
    var affect = _res_mgr.dispatch_by_num(dice.get_last_num())
    broadcast_bank_info()
    for player in affect.keys():
        change_card_info(player)
        broadcast_notification(Notification.get_res(player, affect[player]))


# 初始化分配资源
func initial_resource(player_name: String):
    _res_mgr.set_robber(robber_pos)
    var result = _res_mgr.dispatch_initial_res(player_name)
    broadcast_bank_info()
    change_card_info(player_name)
    broadcast_notification(Notification.get_res(player_name, result))


# 延迟
func delay(second: float):
    _logger.logi("延迟[%.1f]s" % second)
    set_process(false)
    yield(get_tree().create_timer(second), "timeout")
    set_process(true)


# 丢弃资源
func discard_resource():
    var discard_players = _res_mgr.get_discard_players()
    for player in discard_players:
        notify_discard_res(player)


# 设置出卡状态
func set_play_card_state(player_name: String, is_play: bool):
    player_personals[player_name].is_played_card = is_play
    change_personal_info(player_name)


# 更新胜点信息
func update_vp(player_name):
    _vp_mgr.update_vp(player_name)
    change_personal_info(player_name)


# 更新军队成就
func update_army_archievement(player_name, dev_type):
    if dev_type == Data.CardType.KNIGHT:
        var arch = _vp_mgr.update_army(player_name)
        change_personal_info(player_name)
        if arch.old_holder:
            change_personal_info(arch.old_holder)
            broadcast_notification(Notification.army_archievement(arch.old_holder, false))
        if arch.new_holder:
            broadcast_notification(Notification.army_archievement(arch.new_holder, true))
        if arch.new_holder or arch.old_holder:
            broadcast_assist_info()


# 更新道路成就
func update_road_archievement(player_name):
    var arch = _vp_mgr.update_road(player_name)
    change_personal_info(player_name)
    if arch.old_holder:
        change_personal_info(arch.old_holder)
        broadcast_notification(Notification.road_archievement(arch.old_holder, false))
    if arch.new_holder:
        broadcast_notification(Notification.road_archievement(arch.new_holder, true))
    if arch.new_holder or arch.old_holder:
        broadcast_assist_info()


# 更新连续道路打断
func update_breaked_road(player_name: String, pos: Vector3):
    var breaked_player = _vp_mgr.get_breaked_road_player(player_name, pos)
    if breaked_player:
        update_road_archievement(breaked_player)


# 建筑操作
func building_op(player_name: String, build_type: int):
    if assist_info.turn_num > 0:
        _res_mgr.buy(player_name, build_type)
        broadcast_bank_info()
        change_card_info(player_name)


# 更新揭示
func update_revealed(player_name: String, pos: Vector3):
    for cube_pos in Hexlib.get_corner_adjacency_hex(Hexlib.create_corner(pos)):
        var tile_pos = cube_pos.to_vector3()
        if tile_pos in map_info.tile_map and not revealed_info.contains(tile_pos):
            if map_info.tile_map[tile_pos].has_landform(Data.LandformType.CLOUD):
                revealed_info.add(tile_pos)
                change_revealed_info(tile_pos)
                var res_info = _res_mgr.reveal(player_name, tile_pos)
                if res_info:
                    broadcast_notification(Notification.get_res(player_name, res_info))
                    change_card_info(player_name)

# C2S


# 全部玩家就绪
func client_ready(player_name: String):
    player_buildings[player_name] = Protocol.PlayerBuildingInfo.new()
    player_cards[player_name] = Protocol.PlayerCardInfo.new()
    player_personals[player_name] = Protocol.PlayerPersonalInfo.new()
    change_player_net_state(player_name, NetDefines.PlayerNetState.READY)


# 玩家重连
func client_reconnect(player_name: String):
    _logger.logd("收到玩家[%s]的重连请求, 开始初始化.." % player_name)
    send_reconnect_info(player_name)


# 玩家网络状态改变
func change_player_net_state(player_name: String, state: String):
    _logger.logd("玩家[%s]网络状态变为 '%s'" % [player_name, state])
    player_net_state[player_name] = state


# 修改玩家操作状态
func change_player_op_state(player_name: String, state: String, params: Array=[]):
    _logger.logd("玩家[%s]操作状态变为 '%s', 参数=%s" % [player_name, state, str(params)])
    player_op_state[player_name] = NetDefines.PlayerOpStruct.new(state, params)


# 请求放置定居点
func request_place_settlement(player_name: String):
    change_player_op_state(player_name, NetDefines.PlayerOpState.BUILD_SETTLEMENT)


# 请求放置道路
func request_place_road(player_name: String):
    change_player_op_state(player_name, NetDefines.PlayerOpState.BUILD_ROAD)


# 请求升级城市
func request_upgrade_city(player_name: String):
    change_player_op_state(player_name, NetDefines.PlayerOpState.UPGRADE_CITY)


# 请求购买卡牌
func request_buy_dev_card(player_name: String):
    _res_mgr.buy(player_name, Data.OpType.DEV_CARD)
    broadcast_bank_info()
    change_player_op_state(player_name, NetDefines.PlayerOpState.BUY_DEV_CARD)


# 玩家交易
func request_trade(trade_info: Protocol.TradeInfo):
    _logger.logd("[%s]同[%s]发起交易" % [trade_info.from_player, trade_info.to_player])
    _res_mgr.trade(trade_info)
    change_card_info(trade_info.from_player)
    if trade_info.to_player == Protocol.TradeInfo.BANK:
        broadcast_bank_info()
    else:
        change_card_info(trade_info.to_player)
    broadcast_notification(Notification.trade_res(trade_info))
    broadcast_notification(Notification.get_res(trade_info.from_player, trade_info.get_info))
    broadcast_notification(Notification.get_res(trade_info.to_player, trade_info.pay_info))
    change_player_op_state(trade_info.from_player, NetDefines.PlayerOpState.TRADE)


# 增加指定玩家的定居点
func add_settlement(player_name: String, pos: Vector3):
    player_buildings[player_name].settlement_info.append(pos)
    building_op(player_name, Data.OpType.SETTLEMENT)
    update_vp(player_name)
    change_building_info(player_name)
    broadcast_notification(Notification.place_settlement(player_name))
    update_breaked_road(player_name, pos)
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)
    update_revealed(player_name, pos)


# 增加指定玩家的道路
func add_road(player_name: String, road: Protocol.RoadInfo, is_need_res: bool):
    player_buildings[player_name].road_info.append(road)
    if is_need_res:
        building_op(player_name, Data.OpType.ROAD)
    change_building_info(player_name)
    update_road_archievement(player_name)
    broadcast_notification(Notification.place_road(player_name))
    update_revealed(player_name, road.begin_node)
    update_revealed(player_name, road.end_node)
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 增加指定玩家城市
func upgrade_city(player_name: String, pos: Vector3):
    player_buildings[player_name].city_info.append(pos)
    player_buildings[player_name].settlement_info.erase(pos)
    building_op(player_name, Data.OpType.CITY)
    update_vp(player_name)
    change_building_info(player_name)
    broadcast_notification(Notification.upgrade_city(player_name))
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 打出卡牌
func request_play_card(player_name: String, dev_type: int):
    _logger.logd("玩家[%s]打出卡牌[%d]" % [player_name, dev_type])
    _card_mgr.play_card(player_name, dev_type)
    update_army_archievement(player_name, dev_type)
    change_card_info(player_name)
    broadcast_notification(Notification.play_card(player_name, dev_type))
    change_player_op_state(player_name, NetDefines.PlayerOpState.PLAY_CARD, [dev_type])


# 丢弃资源完毕
func discard_done(player_name: String, discard_info: Dictionary):
    _logger.logd("玩家[%s]丢弃资源[%s]" % [player_name, discard_info])
    _res_mgr.recycle_player_res(player_name, discard_info)
    change_card_info(player_name)
    broadcast_bank_info()
    broadcast_notification(Notification.discard_res(player_name, discard_info))
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 移动强盗完毕
func move_robber_done(player_name: String, pos: Vector3):
    _logger.logd("玩家[%s]强盗移动至%s" % [player_name, str(pos)])
    robber_pos = pos
    broadcast_robber_pos()
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)

    
# 抢劫玩家完毕
func rob_player_done(robber: String, robbed_player: String):
    _logger.logd("玩家[%s]抢劫玩家[%s]" % [robber, robbed_player])
    var rob_result = _res_mgr.rob_resource(robber, robbed_player)
    if rob_result:
        broadcast_notification(Notification.player_robbed(robber, robbed_player))
        change_card_info(robber)
        change_card_info(robbed_player)
    change_player_net_state(robber, NetDefines.PlayerNetState.DONE)


# 选择资源完毕
func choose_res_done(player_name: String, res_info: Dictionary):
    _logger.logd("玩家[%s]选择资源%s" % [player_name, res_info])
    var result = _res_mgr.dispatch_player_res(player_name, res_info)
    broadcast_notification(Notification.get_res(player_name, result))
    broadcast_bank_info()
    change_card_info(player_name)
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 选择垄断资源完毕
func choose_mono_type_done(player_name: String, type: int):
    _logger.logd("玩家[%s]选择资源[%s]" % [player_name, type])
    var affect = _res_mgr.monopoly_res(player_name, type)
    for player in affect:
        if player == player_name:
            broadcast_notification(Notification.get_res(player, affect[player]))
        else:
            broadcast_notification(Notification.lost_res(player, affect[player]))
        change_card_info(player)
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 玩家准备退出
func ready_to_exit(player_name: String):
    _logger.logd("玩家[%s]准备退出" % [player_name])
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 玩家取消操作
func cancel_op(player_name: String):
    _logger.logd("玩家[%s]取消操作" % [player_name])
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# S2C

# 发送重连数据
func send_reconnect_info(player_name: String):
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "init_building_info", Protocol.serialize(player_buildings))
    PlayingNet.rpc_id(peer_id, "init_card_info", Protocol.serialize(player_cards))
    PlayingNet.rpc_id(peer_id, "init_personal_info", Protocol.serialize(player_personals))
    PlayingNet.rpc_id(peer_id, "change_bank_info", Protocol.serialize(bank_info))
    PlayingNet.rpc_id(peer_id, "change_assist_info", Protocol.serialize(assist_info))
    PlayingNet.rpc_id(peer_id, "change_robber_pos", robber_pos)
    PlayingNet.rpc_id(peer_id, "change_dice", dice.get_last_roll())
    PlayingNet.rpc_id(peer_id, "send_reconnect_data_done")
    PlayingNet.rpc_id(peer_id, "init_revealed_info", revealed_info.values())
    _logger.logd("发送重连数据到玩家[%s]完毕!" % [player_name])


# 通知玩家放置定居点
func notify_place_settlement(player_name: String, type: int):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]放置定居点" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "place_settlement", type)


# 通知玩家放置道路
func notify_place_road(player_name: String, type: int):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]放置道路" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "place_road", type)


# 通知玩家放置道路
func notify_upgrade_city(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]升级城市" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "upgrade_city")


# 分配指定玩家卡牌
func give_dev_card(player_name):
    var type = _card_mgr.give_card_to_player(player_name)
    _logger.logd("分配玩家[%s]发展卡[%d]" % [player_name, type])
    change_card_info(player_name)
    if type == Data.CardType.VP:
        update_vp(player_name)
    broadcast_bank_info()
    broadcast_notification(Notification.buy_card(player_name))


# 通知玩家自由行动
func notify_free_action(player_name: String):
    _logger.logd("通知玩家[%s]自由行动" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "into_free_action")


# 广播辅助信息
func broadcast_assist_info():
    _logger.logd("广播辅助信息[%s]" % assist_info)
    PlayingNet.rpc("change_assist_info", Protocol.serialize(assist_info))


# 广播银行信息
func broadcast_bank_info():
    _logger.logd("广播银行信息[%s]" % bank_info)
    PlayingNet.rpc("change_bank_info", Protocol.serialize(bank_info))


# 广播建筑信息
func broadcast_building_info():
    _logger.logd("广播建筑信息[%s]" % player_buildings)
    PlayingNet.rpc("init_building_info", Protocol.serialize(player_buildings))


# 广播卡牌信息
func broadcast_card_info():
    _logger.logd("广播卡牌信息[%s]" % player_cards)
    PlayingNet.rpc("init_card_info", Protocol.serialize(player_cards))


# 广播卡牌信息
func broadcast_personal_info():
    _logger.logd("广播个人信息[%s]" % player_personals)
    PlayingNet.rpc("init_personal_info", Protocol.serialize(player_personals))


# 广播通知
func broadcast_notification(notification_info: Protocol.NotificationInfo):
    _logger.logd("广播通知[%s]" % notification_info)
    PlayingNet.rpc("send_notification", Protocol.serialize(notification_info))


# 广播骰子信息
func broadcast_dice_info(info: Array):
    _logger.logd("广播骰子信息[%d, %d]" % info)
    PlayingNet.rpc("change_dice", info)


# 广播揭示信息
func broadcast_revealed_info():
    _logger.logd("广播揭示信息 [%s]" % revealed_info)
    PlayingNet.rpc("init_revealed_info", revealed_info.values())



# 展示结算面板
func broadcast_show_score_panel():
    set_stat_info()
    _logger.logd("通知胜利者[%s]诞生, 展示分数画面" % [stat_info.winner_name])
    for player_name in player_personals:
        change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    PlayingNet.rpc("show_score_panel", Protocol.serialize(stat_info))


# 退出到准备界面
func broadcast_exit_to_prepare():
    _logger.logd("通知退出到准备界面")
    PlayingNet.rpc("exit_to_prepare")


# 更新玩家建筑信息
func change_building_info(player_name: String):
    _logger.logd("更新玩家[%s]建筑信息[%s]" % [player_name, player_buildings[player_name]])
    PlayingNet.rpc("change_building_info", player_name, Protocol.serialize(player_buildings[player_name]))


# 更新玩家卡牌信息
func change_card_info(player_name: String):
    _logger.logd("更新玩家[%s]卡牌信息[%s]" % [player_name, player_cards[player_name]])
    PlayingNet.rpc("change_card_info", player_name, Protocol.serialize(player_cards[player_name]))


# 更新玩家个人信息
func change_personal_info(player_name: String):
    _logger.logd("更新玩家[%s]个人信息改变[%s]" % [player_name, player_personals[player_name]])
    PlayingNet.rpc("change_personal_info", player_name, Protocol.serialize(player_personals[player_name]))


# 更新揭示位置
func change_revealed_info(pos: Vector3):
    _logger.logd("揭示位置: [%s]" % pos)
    PlayingNet.rpc("change_revealed_info", pos)


# 移动强盗
func notify_move_robber(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]移动强盗..." % player_name)
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "move_robber")
    broadcast_notification(Notification.move_robber(player_name))


# 更新强盗位置
func broadcast_robber_pos():
    _logger.logd("更新强盗位置[%s]" % str(robber_pos))
    PlayingNet.rpc("change_robber_pos", robber_pos)


# 通知抢劫玩家
func notify_rob_player(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]抢劫玩家..." % player_name)
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "rob_player")


# 通知丢弃资源
func notify_discard_res(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]丢弃资源" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "discard_resource")

   
# 通知特殊出卡
func notify_special_play(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]特殊出牌" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "special_play")


# 通知特殊建造
func notify_special_building(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]进入特殊建筑阶段" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "into_special_building")
    broadcast_notification(Notification.special_building(player_name))


# 通知选择获得资源
func notify_choose_res(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]选择获得的资源" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "choose_res")


# 通知选择垄断类型
func notify_choose_mono_type(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]选择垄断的资源类型" % [player_name])
    var peer_id = PlayerInfoMgr.get_peer(player_name)
    PlayingNet.rpc_id(peer_id, "choose_mono_type")