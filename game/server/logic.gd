extends Node


# 游戏中服务器

const State: Script = preload("res://game/server/state.gd")
const Dice: Script = preload("res://game/server/dice.gd")
const ResMgr: Script = preload("res://game/server/res_mgr.gd")


var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo

var player_buildings: Dictionary
var player_scores: Dictionary
var assist_info: Protocol.AssistInfo

var player_state: Dictionary
var dice: Dice

var _server_state: HSM.StateMachine
var _robber_pos: Vector3
var _res_mgr: ResMgr


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
    _res_mgr = ResMgr.new(map_info, player_buildings, player_scores, setup_info.catan_size)


func _init_robber():
    var canditate_pos = []
    for tile in map_info.grid_map.values():
        if tile.tile_type == Data.TileType.DESERT:
            canditate_pos.append(tile.cube_pos)
    canditate_pos.shuffle()
    _robber_pos = canditate_pos[0]


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


# 投掷骰子
func roll_dice():
    broadcast_dice_info(dice.roll())


# 分发资源
func dispatch_resource():
    _res_mgr.set_robber(_robber_pos)
    var affect = _res_mgr.dispatch_by_num(dice.get_last_num())
    for player in affect.values():
        change_score_info(player)


# 初始化分配资源
func initial_resource(player_name: String):
    _res_mgr.set_robber(_robber_pos)
    _res_mgr.dispatch_initial_res(player_name)
    change_score_info(player_name)


# 延迟
func delay(second: float):
    Log.logi("[server]延迟[%.1f]s" % second)
    set_process(false)
    yield(get_tree().create_timer(second), "timeout")
    set_process(true)


# 分配资源


# C2S

# 玩家状态改变

func client_ready(player_name: String):
    _init_player(player_name)
    change_player_state(player_name, NetDefines.PlayerState.READY)


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


# 通知玩家自由行动
func notify_free_action(player_name: String):
    Log.logd("[server]通知玩家[%s]自由行动" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "into_free_action")


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


# 广播骰子信息
func broadcast_dice_info(info: Array):
    Log.logd("[server]广播骰子信息[%d, %d]" % info)
    PlayingNet.rpc("change_dice", info)


# 更新玩家建筑信息
func change_building_info(player_name: String):
    Log.logd("[server]更新玩家[%s]建筑信息[%s]" % [player_name, player_buildings[player_name]])
    PlayingNet.rpc("change_building_info", player_name, Protocol.serialize(player_buildings[player_name]))


# 更新玩家分数信息
func change_score_info(player_name: String):
    Log.logd("[server]更新玩家[%s]分数信息[%s]" % [player_name, player_scores[player_name]])
    PlayingNet.rpc("change_score_info", player_name, Protocol.serialize(player_scores[player_name]))


# 移动强盗
func move_robber(player_name: String):
    Log.logd("[server]玩家[%s]移动强盗..." % player_name)


# 更新强盗位置
func broadcast_robber_pos():
    Log.logd("[server]更新强盗位置[%s]" % str(_robber_pos))
    PlayingNet.change_robber_pos(_robber_pos)