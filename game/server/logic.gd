extends Node


# 游戏中服务器

const State: Script = preload("res://game/server/state.gd")


var player_buildings: Dictionary
var player_scores: Dictionary
var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo
var assist_info: Protocol.AssistInfo
var player_state: Dictionary

var _server_state: HSM.StateMachine


# 初始化服务器数据
func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map
    assist_info = Protocol.AssistInfo.new()


func _ready():
    _init_node_setup()
    if GameServer.is_server():
        _init_state_machine()
        _init_player_state()
        ConnState.to_playing(order_info.order_to_name.values())
    else:
        self.set_process(false)
    Log.logi("游戏服务端启动...")


func _init_node_setup():
    name = NetDefines.SERVER_NAME
    add_to_group(NetDefines.SERVER_NAME)


func _init_player_state():
    for name in order_info.order_to_name.values():
        player_state[name] = NetDefines.PlayerOpState.NOT_READY


func _process(delta):
    var old_state = String(_server_state.get_states_path())
    var result = _server_state.update()
    var new_state = String(_server_state.get_states_path())
    if old_state != new_state:
        Log.logd("服务端状态改变%s->%s" % [old_state, new_state])
    _execute_result(result)
    

func _execute_result(result: HSM.UpdateResult):
    for action in result.actions:
        action.invoke()


func _init_state_machine():
    _server_state = State.CatanStateMachine.new(self)


# Public

# 设置当前玩家回合名称
func set_cur_turn_name(player_name: String):
    assist_info.player_turn_name = player_name
    broadcast_assist_info()


# 设置当前大回合数
func update_turn_num():
    assist_info.turn_num += 1
    broadcast_assist_info()


# 增加指定玩家的定居点
func add_settlement(player_name: String):
    pass


# 增加指定玩家的道路
func add_road(player_name):
    pass

# C2S

# 玩家状态改变
func change_player_state(player_name: String, state: int):
    Log.logd("玩家[%s]状态变为 %d" % [player_name, state])
    player_state[player_name] = state


# S2C

# 通知玩家放置定居点
func notify_place_settlement(player_name):
    Log.logd("通知玩家[%s]放置定居点" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "place_settlement")


# 通知玩家放置道路
func notify_place_road(player_name):
    Log.logd("通知玩家[%s]放置道路" % [player_name])
    var peer_id = PlayerInfoMgr.get_info(player_name).peer_id
    PlayingNet.rpc_id(peer_id, "place_road")


# 广播辅助信息
func broadcast_assist_info():
    Log.logd("广播辅助信息[%s]" % assist_info)
    PlayingNet.rpc("change_assist_info", Protocol.serialize(assist_info))