extends Node


# 游戏中客户端


signal assist_info_changed(assist_info)  # 辅助信息改变
signal building_info_changed(player_name, building_info)  # 建筑信息改变
signal score_info_changed(player_name, score_info)  # 得分信息改变
signal client_state_changed(state)  # 客户端状态改变
signal dice_changed(info)  # 骰子变化
signal robber_pos_changed(pos)  # 强盗位置变化
signal resource_discarded(num)  # 丢弃资源


const BuildMgr: Script = preload("res://game/client/build_mgr.gd")


var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo

var assist_info: Protocol.AssistInfo
var player_buildings: Dictionary
var player_scores: Dictionary

var point_info: StdLib.Set

var client_state: String  # 客户端状态

var _build_mgr: BuildMgr
var _logger: Log.Logger


func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map
    _init_local_info()

func _init_local_info():
    client_state = NetDefines.ClientState.IDLE
    assist_info = Protocol.AssistInfo.new()
    player_buildings = {}
    player_scores = {}
    _build_mgr = BuildMgr.new(map_info, player_buildings, player_scores, setup_info.catan_size)


func _ready():
    _logger = Log.get_logger(Log.LogModule.CLIENT)
    _init_node_setup()
    _logger.logi("游戏客户端启动...")


func _init_node_setup():
    name = NetDefines.CLIENT_NAME
    add_to_group(NetDefines.CLIENT_NAME)


# Pub

# 启动客户端
func start():
    PlayingNet.rpc("client_ready", get_name())


# 获得玩家名称
func get_name() -> String:
    return PlayerInfoMgr.get_self_info().player_name


# 获得提示点位
func get_point_info() -> StdLib.Set:
    return _build_mgr.get_point_info()


# 获得所有的可放置点位
func get_available_point() -> Array:
    return _build_mgr.get_available_point()


# 获得布置阶段所有的可放置道路
func get_setup_available_road() -> Array:
    return _build_mgr.get_setup_available_road()


# 获得回合阶段所有的可放置道路
func get_turn_available_road() -> Array:
    var result = []
    return result


# 设置客户端状态
func change_client_state(state: String):
    client_state = state
    _logger.logd("客户端状态变为 '%s'" % [state])
    emit_signal("client_state_changed", client_state)


# C2S


# 放置定居点完毕
func place_settlement_done(pos: Vector3):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("place_settlement_done", get_name(), pos)


# 放置道路完毕
func place_road_done(road: Protocol.RoadInfo):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("place_road_done", get_name(), Protocol.serialize(road))


# 通知丢弃结果
func discard_done(discard_info: Dictionary):
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("discard_done", get_name(), Protocol.serialize(discard_info))


# 让过回合
func pass_turn():
    _logger.logd("玩家[%s]让过回合" % get_name())
    change_client_state(NetDefines.ClientState.IDLE)
    PlayingNet.rpc("pass_turn", get_name())


# S2C


# 放置定居点
func place_settlement():
    change_client_state(NetDefines.ClientState.PLACE_SETTLEMENT)


# 放置道路
func place_road(is_setup: bool):
    change_client_state(NetDefines.ClientState.PLACE_ROAD_SETUP if is_setup else NetDefines.ClientState.PLACE_ROAD_TURN)


# 修改辅助信息
func change_assist_info(info: Protocol.AssistInfo):
    _logger.logd("辅助信息变化[%s]" % info)
    assist_info = info
    emit_signal("assist_info_changed", info)


# 更新骰子
func change_dice(info: Array):
    _logger.logd("骰子变化[%d, %d]" % info)
    emit_signal("dice_changed", info)


# 初始化玩家的建筑信息
func init_building_info(building_infos: Dictionary):
    _logger.logd("建筑信息初始化[%s]" % [building_infos])
    for name in building_infos:
        player_buildings[name] = building_infos[name]
        emit_signal("building_info_changed", name, building_infos[name])


# 初始化玩家的分数信息
func init_score_info(score_infos: Dictionary):
    _logger.logd("分数信息初始化[%s]" % [score_infos])
    for name in score_infos:
        player_scores[name] = score_infos[name]
        emit_signal("score_info_changed", name, score_infos[name])


# 修改指定玩家的建筑信息
func change_building_info(player_name: String, building_info: Protocol.PlayerBuildingInfo):
    _logger.logd("玩家[%s]的建筑信息改变[%s]" % [player_name, building_info])
    player_buildings[player_name] = building_info
    emit_signal("building_info_changed", player_name, building_info)


# 修改指定玩家的分数信息
func change_score_info(player_name: String, score_info: Protocol.PlayerScoreInfo):
    _logger.logd("玩家[%s]的分数信息改变[%s]" % [player_name, score_info])
    player_scores[player_name] = score_info
    emit_signal("score_info_changed", player_name, score_info)


# 修改强盗位置
func change_robber_pos(pos: Vector3):
    _logger.logd("强盗移动至[%s]" % str(pos))
    emit_signal("robber_pos_changed", pos)


# 自由行动阶段
func into_free_action():
    change_client_state(NetDefines.ClientState.FREE_ACTION)


# 丢弃资源
func discard_resource(num: int):
    change_client_state(NetDefines.ClientState.DISCARD_RESOURCE)
    emit_signal("resource_discarded", num)