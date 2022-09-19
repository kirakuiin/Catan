extends Node


# 游戏中客户端


signal assist_info_changed(assist_info)  # 辅助信息改变
signal building_info_changed(player_name, building_info)  # 建筑信息改变
signal score_info_changed(player_name, score_info)  # 得分信息改变


var assist_info: Protocol.AssistInfo
var player_buildings: Dictionary
var player_scores: Dictionary


func _init():
    assist_info = Protocol.AssistInfo.new()
    player_buildings = {}
    player_scores = {}


func _ready():
    _init_node_setup()
    Log.logi("游戏客户端启动...")
    PlayingNet.rpc("client_ready", get_name())


func get_name() -> String:
    return PlayerInfoMgr.get_self_info().player_name


func _init_node_setup():
    name = NetDefines.CLIENT_NAME
    add_to_group(NetDefines.CLIENT_NAME)


# C2S

# TODO: 填充真实逻辑
func place_settlement():
    Log.logd("开始放置定居点...")
    yield(get_tree().create_timer(2), "timeout")
    PlayingNet.rpc("place_settlement_done", get_name())


# TODO: 填充真实逻辑
func place_road():
    Log.logd("开始放置道路...")
    yield(get_tree().create_timer(2), "timeout")
    PlayingNet.rpc("place_road_done", get_name())


# 让过回合
func pass_turn():
    Log.logd("玩家[%s]让过回合" % get_name())
    PlayingNet.rpc("pass_turn", get_name())


# S2C

# 修改辅助信息
func change_assist_info(info: Protocol.AssistInfo):
    Log.logd("辅助信息变化[%s]" % info)
    assist_info = info
    emit_signal("assist_info_changed", info)


# 初始化玩家的建筑信息
func init_building_info(building_infos: Dictionary):
    Log.logd("建筑信息初始化[%s]" % [building_infos])
    player_buildings = building_infos
    for name in building_infos:
        emit_signal("building_info_changed", name, building_infos[name])


# 初始化玩家的分数信息
func init_score_info(score_infos: Dictionary):
    Log.logd("分数信息初始化[%s]" % [score_infos])
    player_scores = score_infos
    for name in score_infos:
        emit_signal("score_info_changed", name, score_infos[name])


# 修改指定玩家的建筑信息
func change_building_info(player_name: String, building_info: Protocol.PlayerBuildingInfo):
    Log.logd("玩家[%s]的建筑信息改变[%s]" % [player_name, building_info])
    emit_signal("building_info_changed", player_name, building_info)


# 修改指定玩家的分数信息
func change_score_info(player_name: String, score_info: Protocol.PlayerScoreInfo):
    Log.logd("玩家[%s]的分数信息改变[%s]" % [player_name, score_info])
    emit_signal("score_info_changed", player_name, score_info)