extends Node


# 游戏中客户端


signal assist_info_changed(assist_info)  # 辅助信息改变
signal bank_info_changed(bank_info)  # 银行信息改变
signal building_info_changed(player_name, building_info)  # 建筑信息改变
signal card_info_changed(player_name, card_info)  # 得分信息改变
signal personal_info_changed(player_name, personal_info)  # 个人信息改变
signal revealed_info_changed(pos)  # 揭示信息改变
signal client_state_changed(state, params)  # 客户端状态改变
signal notification_received(message)  # 服务器通知
signal dice_changed(info)  # 骰子变化
signal robber_pos_changed(pos)  # 强盗位置变化
signal player_hint_showed(hint, always_show)  # 提示信息变化
signal stat_info_received(msg)  # 收到结算消息
signal reconnect_overed()  # 重连完毕
signal exit_game()  # 退出游戏


const BuildMgr: Script = preload("res://game/client/build_mgr.gd")
const OpMgr: Script = preload("res://game/client/op_mgr.gd")
const TradeMgr: Script = preload("res://game/client/trade_mgr.gd")
const SettingMgr: Script = preload("res://game/client/setting_mgr.gd")
const StateMgr: Script = preload("res://game/client/state_mgr.gd")


var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo

var assist_info: Protocol.AssistInfo
var bank_info: Protocol.BankInfo
var revealed_info: StdLib.Set
var player_buildings: Dictionary
var player_cards: Dictionary
var player_personals: Dictionary

var client_state: String  # 客户端状态

var build_mgr: BuildMgr
var op_mgr: OpMgr
var setting_mgr: SettingMgr
var trade_mgr: TradeMgr
var state_mgr: StateMgr

onready var _logger: Log.Logger = Log.get_logger(Log.LogModule.CLIENT)


func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map
    _init_trade()
    _init_local_info()

func _init_local_info():
    client_state = NetDefines.ClientState.IDLE
    assist_info = Protocol.AssistInfo.new()
    bank_info = Protocol.BankInfo.new()
    player_buildings = {}
    player_cards = {}
    player_personals = {}
    revealed_info = StdLib.Set.new()
    build_mgr = BuildMgr.new(map_info, player_buildings, player_cards, setup_info.catan_size)
    op_mgr = OpMgr.new(player_buildings, player_cards, map_info)
    setting_mgr = SettingMgr.new()
    state_mgr = StateMgr.new(get_name())
    
func _init_trade():
    trade_mgr = TradeMgr.new()
    trade_mgr.name = NetDefines.TRADE_CENTER
    add_child(trade_mgr)


func _ready():
    _init_node_setup()


func _init_node_setup():
    name = NetDefines.CLIENT_NAME
    add_to_group(NetDefines.CLIENT_NAME)


# Pub

# 启动客户端
func start():
    _logger.logi("游戏客户端启动...")
    PlayingNet.rpc("client_ready", get_name())


# 执行重连过程
func reconnect():
    _logger.logi("游戏客户端执行重连...")
    PlayingNet.rpc("client_reconnect", get_name())


# 获得玩家名称
func get_name() -> String:
    return PlayerInfoMgr.get_self_info().player_name


# 是否处于回合中
func is_on_turn() -> bool:
    return get_name() == assist_info.player_turn_name


# 是否持有资源
func is_have_res() -> bool:
    return StdLib.sum(player_cards[get_name()].res_cards.values()) > 0


# 获得玩家颜色
func get_color(player_name: String) -> Color:
    return UI_Data.ORDER_DATA[order_info.get_order(player_name)]


# 设置客户端状态
func change_client_state(state: String, params: Dictionary={}):
    client_state = state
    state_mgr.save_client_state(state, params)
    _logger.logd("客户端状态变为 '%s', 参数为: %s" % [state, params])
    emit_signal("client_state_changed", client_state, params)


# 发送局部信息
func show_hint(hint: String, is_always_show: bool=false):
    emit_signal("player_hint_showed", hint, is_always_show)


# 判断地块是否是可见地块
func is_visible_tile(pos) -> bool:
    var tile = map_info.tile_map[pos]
    if tile.has_landform(Data.LandformType.CLOUD):
        if not revealed_info.contains(pos):
            return false
    return true
           

# C2S

# 请求放置定居点
func request_place_settlement():
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("request_place_settlement", get_name())


# 请求放置道路
func request_place_road():
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("request_place_road", get_name())


# 请求升级城市
func request_upgrade_city():
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("request_upgrade_city", get_name())


# 请求购买卡牌
func request_buy_dev_card():
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("request_buy_dev_card", get_name())


# 请求打出卡牌
func request_play_card(dev_type: int):
    _logger.logd("玩家[%s]打出卡牌[%d]" % [get_name(), dev_type])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("request_play_card", get_name(), dev_type)


# 请求交易
func request_trade(trade_info: Protocol.TradeInfo):
    _logger.logd("玩家[%s]发起交易[%s]" % [get_name(), trade_info])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("request_trade", Protocol.serialize(trade_info))


# 放置定居点完毕
func place_settlement_done(pos: Vector3):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("place_settlement_done", get_name(), pos)


# 放置道路完毕
func place_road_done(road: Protocol.RoadInfo, is_need_res: bool):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("place_road_done", get_name(), Protocol.serialize(road), is_need_res)


# 升级城市完毕
func upgrade_city_done(pos: Vector3):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("upgrade_city_done", get_name(), pos)


# 通知丢弃结果
func discard_done(discard_info: Dictionary):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("discard_done", get_name(), Protocol.serialize(discard_info))


# 让过回合
func pass_turn():
    _logger.logd("玩家[%s]让过回合" % get_name())
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("pass_turn", get_name())


# 移动强盗位置完毕
func move_robber_done(pos: Vector3):
    _logger.logd("玩家[%s]移动强盗至[%s]" % [get_name(), str(pos)])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("move_robber_done", get_name(), pos)


# 抢劫玩家完毕
func rob_player_done(player: String):
    _logger.logd("玩家[%s]抢劫玩家[%s]" % [get_name(), player])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("rob_player_done", get_name(), player)


# 选择资源完毕
func choose_res_done(result: Dictionary):
    _logger.logd("玩家[%s]选择资源%s" % [get_name(), str(result)])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("choose_res_done", get_name(), result)


# 选择垄断类型完毕
func choose_mono_type_done(result: int):
    _logger.logd("玩家[%s]选择垄断资源[%s]" % [get_name(), str(result)])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("choose_mono_type_done", get_name(), result)


# 准备退出游戏
func ready_to_exit():
    _logger.logd("玩家[%s]准备退出" % [get_name()])
    PlayingNet.rpc("ready_to_exit", get_name())


# 取消操作
func cancel_op():
    _logger.logd("玩家[%s]取消操作" % [get_name()])
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("cancel_op", get_name())

# S2C


# 放置定居点
func place_settlement(type: int):
    change_client_state(NetDefines.ClientState.PLACE_SETTLEMENT, {"type": type})
    show_hint("请放置定居点...")


# 放置道路
func place_road(type: int):
    change_client_state(NetDefines.ClientState.PLACE_ROAD, {"type": type})
    show_hint("请放置道路...")


# 升级城市
func upgrade_city():
    change_client_state(NetDefines.ClientState.UPGRADE_CITY)
    show_hint("请升级城市...")


# 修改辅助信息
func change_assist_info(info: Protocol.AssistInfo):
    _logger.logd("辅助信息变化[%s]" % info)
    assist_info = info
    emit_signal("assist_info_changed", info)


# 修改银行信息
func change_bank_info(info: Protocol.BankInfo):
    _logger.logd("银行信息变化[%s]" % info)
    bank_info = info
    emit_signal("bank_info_changed", info)


# 更新骰子
func change_dice(info: Array):
    _logger.logd("骰子变化[%d, %d]" % info)
    emit_signal("dice_changed", info)


# 初始化玩家的建筑信息
func init_building_info(building_infos: Dictionary):
    _logger.logd("建筑信息初始化[%s]" % [building_infos])
    for name in building_infos:
        change_building_info(name, building_infos[name])


# 初始化玩家的卡牌信息
func init_card_info(card_infos: Dictionary):
    _logger.logd("卡牌信息初始化[%s]" % [card_infos])
    for name in card_infos:
        change_card_info(name, card_infos[name])


# 初始化玩家的个人信息
func init_personal_info(personal_infos: Dictionary):
    _logger.logd("个人信息初始化[%s]" % [personal_infos])
    for name in personal_infos:
        change_personal_info(name, personal_infos[name])


# 初始化揭示信息
func init_revealed_info(info: Array):
    _logger.logd("揭示信息初始化[%s]" % [info])
    for pos in info:
        change_revealed_info(pos)


# 修改指定玩家的建筑信息
func change_building_info(player_name: String, building_info: Protocol.PlayerBuildingInfo):
    _logger.logd("玩家[%s]的建筑信息改变[%s]" % [player_name, building_info])
    player_buildings[player_name] = building_info
    emit_signal("building_info_changed", player_name, building_info)


# 修改指定玩家的卡牌信息
func change_card_info(player_name: String, card_info: Protocol.PlayerCardInfo):
    _logger.logd("玩家[%s]的卡牌信息改变[%s]" % [player_name, card_info])
    player_cards[player_name] = card_info
    emit_signal("card_info_changed", player_name, card_info)


# 修改玩家个人信息
func change_personal_info(player_name: String, personal_info: Protocol.PlayerPersonalInfo):
    _logger.logd("玩家[%s]个人信息改变[%s]" % [player_name, personal_info])
    player_personals[player_name] = personal_info
    emit_signal("personal_info_changed", player_name, personal_info)


# 修改揭示信息
func change_revealed_info(pos: Vector3):
    _logger.logd("揭示信息改变[%s]" % [pos])
    revealed_info.add(pos)
    emit_signal("revealed_info_changed", pos)


# 修改强盗位置
func change_robber_pos(pos: Vector3):
    _logger.logd("强盗移动至[%s]" % str(pos))
    emit_signal("robber_pos_changed", pos)


# 自由行动阶段
func into_free_action():
    if setting_mgr.is_auto_pass and not player_cards[get_name()].is_have_card():
        pass_turn()
    else:
        change_client_state(NetDefines.ClientState.FREE_ACTION)


# 丢弃资源
func discard_resource():
    change_client_state(NetDefines.ClientState.DISCARD_RESOURCE)
    show_hint("请丢弃资源...")


# 移动强盗
func move_robber():
    change_client_state(NetDefines.ClientState.MOVE_ROBBER)
    show_hint("请移动强盗...")


# 抢劫玩家
func rob_player():
    change_client_state(NetDefines.ClientState.ROB_PLAYER)
    show_hint("请抢夺玩家...")


# 特殊出卡
func special_play():
    if setting_mgr.is_auto_pass:
        pass_turn()
    else:
        change_client_state(NetDefines.ClientState.PLAY_BEFORE_DICE)
        show_hint("是否打出骑士卡?", true)


# 进入特殊建筑阶段
func into_special_building():
    if setting_mgr.is_auto_pass and not op_mgr.can_building():
        pass_turn()
    else:
        change_client_state(NetDefines.ClientState.SPECIAL_BUILDING)
        show_hint("特殊建造阶段")


# 选择资源
func choose_res():
    change_client_state(NetDefines.ClientState.CHOOSE_RES)
    show_hint("选择两个任意资源...")


# 选择垄断类型
func choose_mono_type():
    change_client_state(NetDefines.ClientState.CHOOSE_MONO_TYPE)
    show_hint("选择一种类型的资源垄断...")


# 收到通知
func receive_notification(noti_info: Protocol.NotificationInfo):
    emit_signal("notification_received", noti_info)


# 打开分数结算界面
func show_score_panel(stat_info: Protocol.StatInfo):
    _logger.logd("收到结算信息: %s" % [stat_info])
    emit_signal("stat_info_received", stat_info)


# 退出
func exit_to_prepare():
    _logger.logd("退出游戏")
    emit_signal("exit_game")


# 重连结束
func reconnect_done():
    _logger.logd("接收重连数据完毕!")
    emit_signal("reconnect_overed")
    change_client_state(state_mgr.get_client_state(), state_mgr.get_state_params())