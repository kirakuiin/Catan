extends Node

# 游戏状态管理

var game_state: InnerStateInterface = null # 游戏状态


func _ready():
    GameServer.connect("server_disconnected", self, "_on_server_disconnected")
    GameServer.connect("client_disconnected", self, "_on_client_disconnected")
    GameServer.connect("client_connected", self, "_on_client_connected")
    GameServer.connect("network_started", self, "_on_network_started")
    GameServer.connect("network_ended", self, "_on_network_ended")


# 切换至准备状态
func to_prepare():
    game_state = PrepareState.new()


# 切换至游戏状态
func to_playing(player_names: Array):
    game_state = PlayingState.new(player_names)


# 是否接受连接
func is_accept_connection(player_info: Protocol.PlayerInfo) -> bool:
    return game_state.is_accept_connection(player_info)


# 设置最大连接数
func set_max_conn(num: int):
    game_state.max_conn = num


# 内部状态
class InnerStateInterface:
    extends Reference

    var max_conn: int = 3
    var cur_conn: int = 0

    func is_accept_connection(player_info: Protocol.PlayerInfo) -> bool:
        return true

    func get_state() -> int:
        return 0


# 准备状态
class PrepareState:
    extends InnerStateInterface

    func is_accept_connection(player_info: Protocol.PlayerInfo) -> bool:
        return cur_conn < max_conn

    func get_state() -> int:
        return Protocol.HostState.PREPARE


# 游玩状态
class PlayingState:
    extends InnerStateInterface

    var _player_names: Array

    func _init(player_names: Array):
        _player_names = player_names

    func is_accept_connection(player_info: Protocol.PlayerInfo) -> bool:
        return player_info.player_name in _player_names

    func get_state() -> int:
        return Protocol.HostState.PLAYING


func _on_server_disconnected():
    game_state = null


func _on_client_disconnected(peer_id: int):
    game_state.cur_conn -= 1


func _on_client_connected(player_info: Protocol.PlayerInfo):
    game_state.cur_conn += 1


func _on_network_started(peer_id: int):
    to_prepare()


func _on_network_ended():
    game_state = null