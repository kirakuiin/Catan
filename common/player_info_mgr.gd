extends Node


signal player_added(player_info)
signal player_removed(player_info)


var _info_dict: Dictionary = {}
var _logger: Log.Logger


func _ready():
    GameServer.connect("connection_failed", self, "_on_connection_failed")
    GameServer.connect("server_disconnected", self, "_on_server_disconnected")
    GameServer.connect("client_disconnected", self, "_on_client_disconnected")
    GameServer.connect("client_connected", self, "_on_client_connected")
    GameServer.connect("network_started", self, "_on_network_started")
    GameServer.connect("network_ended", self, "_on_network_ended")
    _logger = Log.get_logger(Log.LogModule.CONN)


func add_player_info(player_info: Protocol.PlayerInfo):
    if not player_info.player_name in _info_dict:
        _info_dict[player_info.player_name] = player_info
        emit_signal("player_added", player_info)
        _logger.logd("玩家[%s]加入" % player_info.player_name)
    else:
        _info_dict[player_info.player_name] = player_info


func remove_player_by_id(id: int):
    for player_info in _info_dict.values():
        if player_info.peer_id == id:
            _info_dict.erase(player_info.player_name)
            emit_signal("player_removed", player_info)
            _logger.logd("玩家[%s]离开" % player_info.player_name)


func get_self_info() -> Protocol.PlayerInfo:
    return _info_dict[GameConfig.get_player_name()]


func get_all_info() -> Array:
    return _info_dict.values()


func get_info(name: String) -> Protocol.PlayerInfo:
    return _info_dict[name]


func get_peer(name: String) -> int:
    return get_info(name).peer_id


func reset():
    _info_dict = {}


# client
puppet func recv_all_player_info(net_datas: Array):
    var info_list = Protocol.deserialize(net_datas)
    for player_info in info_list:
        add_player_info(player_info)


# server
func broadcast_player_info(player_info):
    add_player_info(player_info)
    rpc("recv_all_player_info", Protocol.serialize(get_all_info()))


func _on_server_disconnected():
    reset()


func _on_client_disconnected(peer_id: int):
    remove_player_by_id(peer_id)


func _on_client_connected(player_info: Protocol.PlayerInfo):
    broadcast_player_info(player_info)


func _on_connection_failed():
    reset()


func _on_network_started(peer_id: int):
    add_player_info(Protocol.create_player_info_by_id(peer_id))


func _on_network_ended():
    reset()