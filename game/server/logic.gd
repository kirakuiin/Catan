extends Node


# 游戏中服务器

const State: Script = preload("res://game/server/state.gd")


var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo

var player_buildings: Dictionary
var player_scores: Dictionary
var assist_info: Protocol.AssistInfo

var player_state: Dictionary

var _server_state: HSM.StateMachine


# 初始化服务器数据
func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map


func _ready():
    _init_node_setup()
    _init_player_info()
    _init_state_machine()
    _init_player_state()
    ConnState.to_playing(order_info.order_to_name.values())
    Log.logi("[server]游戏服务端启动...")


func _init_node_setup():
    name = NetDefines.SERVER_NAME
    add_to_group(NetDefines.SERVER_NAME)


func _init_player_state():
    for name in order_info.order_to_name.values():
        player_state[name] = NetDefines.PlayerState.NOT_READY


func _init_player_info():
    assist_info = Protocol.AssistInfo.new()
    player_buildings = {}
    player_scores = {}


func _process(delta):
    var old_state = String(_server_state.get_states_path())
    var result = _server_state.update()
    var new_state = String(_server_state.get_states_path())
    if old_state != new_state:
        Log.logd("[server]状态改变%s->%s" % [old_state, new_state])
    _execute_result(result)
    

func _execute_result(result: HSM.UpdateResult):
    for action in result.actions:
        action.invoke()


func _init_state_machine():
    _server_state = State.CatanStateMachine.new(self)
    

func _init_player(player_name: String):
    player_buildings[player_name] = Protocol.PlayerBuildingInfo.new()
    player_scores[player_name] = Protocol.PlayerScoreInfo.new()


# Public

# 设置当前玩家回合名称
func set_cur_turn_name(player_name: String):
    assist_info.player_turn_name = player_name
    broadcast_assist_info()


# 设置当前大回合数
func update_turn_num():
    assist_info.turn_num += 1
    broadcast_assist_info()


# C2S

# 玩家状态改变

func client_ready(player_name: String):
    change_player_state(player_name, NetDefines.PlayerState.READY)
    _init_player(player_name)


func change_player_state(player_name: String, state: String):
    Log.logd("[server]玩家[%s]状态变为 '%s'" % [player_name, state])
    player_state[player_name] = state


# 增加指定玩家的定居点
func add_settlement(player_name: String, pos: Vector3):
    player_buildings[player_name].settlement_info.append(pos)
    change_building_info(player_name)


# 增加指定玩家的道路
func add_road(player_name: String, road: Protocol.RoadInfo):
    player_buildings[player_name].road_info.append(road)
    change_building_info(player_name)

# S2C

# 通知玩家放置定居点
func notify_place_settlement(player_name):
    Log.logd("[server]通知玩家[%s]放置定居点" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "place_settlement")


# 通知玩家放置道路
func notify_place_road(player_name, is_setup=false):
    Log.logd("[server]通知玩家[%s]放置道路" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "place_road", is_setup)


# 广播辅助信息
func broadcast_assist_info():
    Log.logd("[server]广播辅助信息[%s]" % assist_info)
    PlayingNet.rpc("change_assist_info", Protocol.serialize(assist_info))


# 广播建筑信息
func broadcast_building_info():
    Log.logd("[server]广播建筑信息[%s]" % player_buildings)
    PlayingNet.rpc("init_building_info", Protocol.serialize(player_buildings))


# 广播分数信息
func broadcast_score_info():
    Log.logd("[server]广播分数信息[%s]" % player_scores)
    PlayingNet.rpc("init_score_info", Protocol.serialize(player_scores))


# 更新玩家建筑信息
func change_building_info(player_name: String):
    Log.logd("[server]更新玩家[%s]建筑信息[%s]" % [player_name, player_buildings[player_name]])
    PlayingNet.rpc("change_building_info", player_name, Protocol.serialize(player_buildings[player_name]))


# 更新玩家分数信息
func change_score_info(player_name: String):
    Log.logd("[server]更新玩家[%s]分数信息[%s]" % [player_name, player_scores[player_name]])
    PlayingNet.rpc("change_score_info", player_name, Protocol.serialize(player_scores[player_name]))
