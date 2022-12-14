extends Node

# 连接状态管理


signal state_changed(state)  # 状态变化


var game_state: InnerStateInterface = null # 游戏状态

var _logger: Log.Logger


func _ready():
    _logger = Log.get_logger(Log.LogModule.CONN)
    GameServer.connect("server_disconnected", self, "_on_server_disconnected")
    GameServer.connect("client_disconnected", self, "_on_client_disconnected")
    GameServer.connect("client_connected", self, "_on_client_connected")
    GameServer.connect("network_started", self, "_on_network_started")
    GameServer.connect("network_ended", self, "_on_network_ended")


# 切换至准备状态
func to_prepare():
    game_state = PrepareState.new()
    emit_signal("state_changed", game_state.get_state())
    _logger.logd("切换至准备状态")


# 切换至游戏状态
func to_playing(player_names: Array):
    game_state = PlayingState.new(player_names)
    emit_signal("state_changed", game_state.get_state())
    _logger.logd("切换至游戏状态")


# 是否接受连接
func is_accept_connection(player_info: Protocol.PlayerInfo) -> Protocol.ServerResponseInfo:
    return game_state.is_accept_connection(player_info)


# 设置最大连接数
func set_max_conn(num: int):
    game_state.max_conn = num


# 内部状态
class InnerStateInterface:
    extends Reference

    var max_conn: int = 3
    var cur_conn: int = 0

    func is_accept_connection(player_info: Protocol.PlayerInfo) -> Protocol.ServerResponseInfo:
        return Protocol.ServerResponseInfo.new()

    func get_state() -> int:
        return 0


# 准备状态
class PrepareState:
    extends InnerStateInterface

    func is_accept_connection(player_info: Protocol.PlayerInfo) -> Protocol.ServerResponseInfo:
        var result = Protocol.ServerResponseInfo.new()
        if cur_conn >= max_conn:
            result.is_success = false
            result.res_reason = "游戏人数已满!"
        return result

    func get_state() -> int:
        return Data.HostState.PREPARE


# 游玩状态
class PlayingState:
    extends InnerStateInterface

    var _player_names: Array

    func _init(player_names: Array):
        _player_names = player_names

    func is_accept_connection(player_info: Protocol.PlayerInfo) -> Protocol.ServerResponseInfo:
        var result = Protocol.ServerResponseInfo.new()
        if not player_info.player_name in _player_names:
            result.is_success = false
            result.res_reason = "您不是此局游戏的初始玩家, 无法加入进行中的游戏!"
        return result

    func get_state() -> int:
        return Data.HostState.PLAYING


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