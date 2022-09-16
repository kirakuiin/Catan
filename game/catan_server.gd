extends Node


# 游戏中服务器

var _server_state: FSM.StateMachine
var _player_buildings: Dictionary
var _player_scores: Dictionary
var _map_info: Protocol.MapInfo
var _order_info: Protocol.PlayerOrderInfo
var _setup_info: Protocol.CatanSetupInfo


# 初始化服务器数据
func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    _order_info = order
    _setup_info = setup
    _map_info = map


func _ready():
    _init_node_setup()
    if GameServer.is_server():
        ConnState.to_playing(_order_info.order_to_name.values())


func _init_node_setup():
    name = Data.SERVER
    add_to_group(Data.SERVER)


func _process(delta):
    pass


# 初始状态
class InitState:
    extends FSM.State