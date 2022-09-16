extends Node


# 游戏中服务器

var _server_state: HSM.StateMachine
var _player_buildings: Dictionary
var _player_scores: Dictionary
var _map_info: Protocol.MapInfo
var _order_info: Protocol.PlayerOrderInfo
var _setup_info: Protocol.CatanSetupInfo

var _player_state: Dictionary


# 初始化服务器数据
func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    _order_info = order
    _setup_info = setup
    _map_info = map


func _ready():
    _init_node_setup()
    if GameServer.is_server():
        ConnState.to_playing(_order_info.order_to_name.values())
        _init_player_state()


func _init_node_setup():
    name = NetDefines.SERVER_NAME
    add_to_group(NetDefines.SERVER_NAME)


func _init_player_state():
    for name in _order_info.order_to_name.values():
        _player_state[name] = NetDefines.PlayerOpState.NOT_READY


func _process(delta):
    pass


# 玩家就绪
func player_ready(player_name: String):
    _player_state[player_name] = NetDefines.PlayerOpState.READY