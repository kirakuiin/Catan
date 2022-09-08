extends Node


# all
signal network_started(peer_id)  # 启动网络
signal network_ended()  # 网络结束
signal client_disconnected(peer_id)  # 客户端断开连接

# only server
signal client_connected(player_info)  # 客户端成功连接

# only client
signal server_disconnected()  # 服务器断开连接
signal server_accepted()  # 服务器接受连接
signal connection_failed() # 连接失败


var peer = null
var client_ids: Array = []


func _ready():
    get_tree().connect("network_peer_connected", self, "_on_player_connected")
    get_tree().connect("network_peer_disconnected", self,"_on_player_disconnected")
    get_tree().connect("connection_failed", self, "_on_connected_fail")
    get_tree().connect("server_disconnected", self, "_on_server_disconnected")


# 广播数据
static func broadcast(data) -> PacketPeerUDP:
    var client = PacketPeerUDP.new()
    client.set_broadcast_enabled(true)
    client.set_dest_address(NetDefines.BROADCAST_ADDR, NetDefines.BROAD_PORT)
    client.put_var(data)
    return client


# 创建主机
func host_game():
    peer = NetworkedMultiplayerENet.new()
    peer.create_server(NetDefines.GAME_PORT, NetDefines.MAX_PEER)
    get_tree().set_network_peer(peer)
    client_ids = []
    emit_signal("network_started", get_peer_id())


# 加入主机
func join_game(ip: String):
    peer = NetworkedMultiplayerENet.new()
    peer.create_client(ip, NetDefines.GAME_PORT)
    get_tree().set_network_peer(peer)
    emit_signal("network_started", get_peer_id())


# 关闭连接
func close_game():
    if peer:
        peer.close_connection()
        peer = null
        client_ids = []
        get_tree().set_network_peer(null)
        emit_signal("network_ended")


# 判断是否为服务器
func is_server() -> bool:
    return get_tree().is_network_server()


# 获得自身peer id
func get_peer_id() -> int:
    return get_tree().get_network_unique_id()


# 发送自身信息
puppet func send_player_info_to_server():
    rpc("check_player_info", Protocol.serialize(PlayerInfoMgr.get_self_info()))


# 服务器同意连接
puppet func server_accept():
    emit_signal("server_accepted")


# 检查客户端信息
master func check_player_info(net_data):
    var player_info = Protocol.deserialize(net_data) as Protocol.PlayerInfo
    if GameState.is_accept_connection(player_info):
        client_ids.append(player_info.peer_id)
        emit_signal("client_connected", player_info)
        rpc_id(player_info.peer_id, "server_accept")
    else:
        peer.disconnect_peer(player_info.peer_id)


# 客户端断开连接
remotesync func client_disconnect(peer_id: int):
    emit_signal("client_disconnected", peer_id)


# server recv
func _on_player_connected(id):
    if is_server():
        rpc_id(id, "send_player_info_to_server")


func _on_player_disconnected(id):
    if is_server():
        if id in client_ids:
            client_ids.erase(id)
            rpc("client_disconnect", id)
        

# clients recv only
func _on_server_disconnected():
    emit_signal("server_disconnected")


func _on_connected_fail():
    get_tree().set_network_peer(null)
    emit_signal("connection_failed")