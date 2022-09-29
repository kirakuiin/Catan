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

var player_net_state: Dictionary
var player_op_state: Dictionary
var dice: Dice
var has_roll_dice: bool

var _server_state: HSM.StateMachine
var _robber_pos: Vector3
var _res_mgr: ResMgr
var _vp_mgr: VPMgr
var _card_mgr: CardMgr
var _logger: Log.Logger


# 初始化服务器数据
func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map
    dice = Dice.new()


func _ready():
    _logger = Log.get_logger(Log.LogModule.SERVER)
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
    assist_info = Protocol.AssistInfo.new()
    bank_info = Protocol.BankInfo.new(setup_info.catan_size)


func _init_robber():
    var canditate_pos = []
    for tile in map_info.grid_map.values():
        if tile.tile_type == Data.TileType.DESERT:
            canditate_pos.append(tile.cube_pos)
    canditate_pos.shuffle()
    _robber_pos = canditate_pos[0]


func _init_state_machine():
    _server_state = State.CatanStateMachine.new(self)


func _init_player_state():
    for name in order_info.order_to_name.values():
        player_net_state[name] = NetDefines.PlayerNetState.NOT_READY
    for name in order_info.order_to_name.values():
        player_op_state[name] = NetDefines.PlayerOpStruct.new()


func _init_mgr():
    _res_mgr = ResMgr.new(map_info, player_buildings, player_cards, setup_info.catan_size, bank_info)
    _card_mgr = CardMgr.new(player_cards, player_personals, setup_info.catan_size, bank_info)
    _vp_mgr = VPMgr.new(player_cards, player_buildings, player_personals, assist_info)


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
    has_roll_dice = false
    broadcast_assist_info()


# 设置当前大回合数
func update_turn_num():
    assist_info.turn_num += 1
    broadcast_assist_info()


# 投掷骰子
func roll_dice():
    broadcast_dice_info(dice.roll())
    has_roll_dice = true


# 分发资源
func dispatch_resource():
    _res_mgr.set_robber(_robber_pos)
    var affect = _res_mgr.dispatch_by_num(dice.get_last_num())
    broadcast_bank_info()
    for player in affect.keys():
        change_card_info(player)
        broadcast_message(Message.get_res(player, affect[player]))


# 初始化分配资源
func initial_resource(player_name: String):
    _res_mgr.set_robber(_robber_pos)
    var result = _res_mgr.dispatch_initial_res(player_name)
    broadcast_bank_info()
    change_card_info(player_name)
    broadcast_message(Message.get_res(player_name, result))


# 延迟
func delay(second: float):
    _logger.logi("延迟[%.1f]s" % second)
    set_process(false)
    yield(get_tree().create_timer(second), "timeout")
    set_process(true)


# 丢弃资源
func discard_resource():
    var discard_infos = _res_mgr.get_discard_infos()
    for player in discard_infos:
        notify_discard_res(player, discard_infos[player])


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
        if arch.new_holder:
            broadcast_assist_info()
            broadcast_message(Message.army_archievement(arch.new_holder))


# 更新道路成就
func update_road_archievement(player_name):
    #var arch = _vp_mgr.update_road(player_name)
    pass

# C2S


# 全部玩家就绪
func client_ready(player_name: String):
    player_buildings[player_name] = Protocol.PlayerBuildingInfo.new()
    player_cards[player_name] = Protocol.PlayerCardInfo.new()
    player_personals[player_name] = Protocol.PlayerPersonalInfo.new()
    change_player_net_state(player_name, NetDefines.PlayerNetState.READY)


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
    _res_mgr.buy(player_name, Data.OpType.SETTLEMENT)
    broadcast_bank_info()
    change_card_info(player_name)


# 请求放置道路
func request_place_road(player_name: String):
    change_player_op_state(player_name, NetDefines.PlayerOpState.BUILD_ROAD)
    _res_mgr.buy(player_name, Data.OpType.ROAD)
    broadcast_bank_info()
    change_card_info(player_name)


# 请求升级城市
func request_upgrade_city(player_name: String):
    _res_mgr.buy(player_name, Data.OpType.CITY)
    broadcast_bank_info()
    change_player_op_state(player_name, NetDefines.PlayerOpState.UPGRADE_CITY)
    change_card_info(player_name)


# 请求升级城市
func request_buy_dev_card(player_name: String):
    _res_mgr.buy(player_name, Data.OpType.DEV_CARD)
    broadcast_bank_info()
    change_player_op_state(player_name, NetDefines.PlayerOpState.BUY_DEV_CARD)


# 增加指定玩家的定居点
func add_settlement(player_name: String, pos: Vector3):
    player_buildings[player_name].settlement_info.append(pos)
    update_vp(player_name)
    change_building_info(player_name)
    broadcast_message(Message.place_settlement(player_name))
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 增加指定玩家的道路
func add_road(player_name: String, road: Protocol.RoadInfo):
    player_buildings[player_name].road_info.append(road)
    change_building_info(player_name)
    update_road_archievement(player_name)
    broadcast_message(Message.place_road(player_name))
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 增加指定玩家城市
func upgrade_city(player_name: String, pos: Vector3):
    player_buildings[player_name].city_info.append(pos)
    player_buildings[player_name].settlement_info.erase(pos)
    update_vp(player_name)
    change_building_info(player_name)
    broadcast_message(Message.upgrade_city(player_name))
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 打出卡牌
func play_card(player_name: String, dev_type: int):
    _logger.logd("玩家[%s]打出卡牌[%d]" % [player_name, dev_type])
    _card_mgr.play_card(player_name, dev_type)
    update_army_archievement(player_name, dev_type)
    change_card_info(player_name)
    broadcast_message(Message.play_card(player_name, dev_type))
    change_player_op_state(player_name, NetDefines.PlayerOpState.PLAY_CARD, [dev_type])


# 丢弃资源完毕
func discard_done(player_name: String, discard_info: Dictionary):
    _logger.logd("玩家[%s]丢弃资源[%s]" % [player_name, discard_info])
    _res_mgr.recycle_player_res(player_name, discard_info)
    change_card_info(player_name)
    broadcast_bank_info()
    broadcast_message(Message.discard(player_name, discard_info))
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 移动强盗完毕
func move_robber_done(player_name: String, pos: Vector3):
    _logger.logd("玩家[%s]强盗移动至%s" % [player_name, str(pos)])
    _robber_pos = pos
    broadcast_robber_pos()
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)

    
# 抢劫玩家完毕
func rob_player_done(robber: String, robbed_player: String):
    _logger.logd("玩家[%s]抢劫玩家[%s]" % [robber, robbed_player])
    var rob_result = _res_mgr.rob_resource(robber, robbed_player)
    if rob_result:
        broadcast_message(Message.rob_player(robber, robbed_player))
        change_card_info(robber)
        change_card_info(robbed_player)
    change_player_net_state(robber, NetDefines.PlayerNetState.DONE)


# 选择资源完毕
func choose_res_done(player_name: String, res_info: Dictionary):
    _logger.logd("玩家[%s]选择资源%s" % [player_name, res_info])
    var result = _res_mgr.bank_give_res(player_name, res_info)
    broadcast_message(Message.get_res(player_name, result))
    broadcast_bank_info()
    change_card_info(player_name)
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)


# 选择垄断资源完毕
func choose_mono_type_done(player_name: String, type: int):
    _logger.logd("玩家[%s]选择资源[%s]" % [player_name, type])
    var affect = _res_mgr.monopoly_res(player_name, type)
    for player in affect:
        if player == player_name:
            broadcast_message(Message.get_res(player, affect[player]))
        else:
            broadcast_message(Message.lost_res(player, affect[player]))
        change_card_info(player)
    change_player_net_state(player_name, NetDefines.PlayerNetState.DONE)

# S2C

# 通知玩家放置定居点
func notify_place_settlement(player_name: String, is_setup: bool):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]放置定居点" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "place_settlement", is_setup)


# 通知玩家放置道路
func notify_place_road(player_name: String, is_setup: bool):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]放置道路" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "place_road", is_setup)


# 通知玩家放置道路
func notify_upgrade_city(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]升级城市" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "upgrade_city")


# 分配指定玩家卡牌
func give_dev_card(player_name):
    var type = _card_mgr.give_card_to_player(player_name)
    _logger.logd("分配玩家[%s]发展卡[%d]" % [player_name, type])
    if type == Data.CardType.VP:
        update_vp(player_name)
    broadcast_bank_info()
    change_card_info(player_name)
    broadcast_message(Message.buy_dev_card(player_name))


# 通知玩家自由行动
func notify_free_action(player_name: String):
    _logger.logd("通知玩家[%s]自由行动" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
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


# 广播消息
func broadcast_message(message: Protocol.MessageInfo):
    _logger.logd("广播消息[%s]" % message)
    PlayingNet.rpc("show_message", Protocol.serialize(message))


# 广播骰子信息
func broadcast_dice_info(info: Array):
    _logger.logd("广播骰子信息[%d, %d]" % info)
    PlayingNet.rpc("change_dice", info)


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


# 移动强盗
func notify_move_robber(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]移动强盗..." % player_name)
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "move_robber")


# 更新强盗位置
func broadcast_robber_pos():
    _logger.logd("更新强盗位置[%s]" % str(_robber_pos))
    PlayingNet.rpc("change_robber_pos", _robber_pos)


# 通知抢劫玩家
func notify_rob_player(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知玩家[%s]抢劫玩家..." % player_name)
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "rob_player")


# 通知丢弃资源
func notify_discard_res(player_name: String, num: int):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]丢弃[%d]资源" % [player_name, num])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "discard_resource", num)

   
# 通知特殊出卡
func notify_special_play(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]特殊出牌" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "special_play")


# 通知选择获得资源
func notify_choose_res(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]选择获得的资源" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "choose_res")


# 通知选择垄断类型
func notify_choose_mono_type(player_name: String):
    change_player_net_state(player_name, NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
    _logger.logd("通知[%s]选择垄断的资源类型" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "choose_mono_type")