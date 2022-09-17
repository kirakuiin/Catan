extends Node


# 游戏中客户端


func _init():
    pass


func _ready():
    _init_node_setup()
    Log.logi("游戏客户端启动...")
    PlayingNet.rpc("client_ready", _get_name())


func _get_name() -> String:
    return PlayerInfoMgr.get_self_info().player_name


func _init_node_setup():
    name = NetDefines.CLIENT_NAME
    add_to_group(NetDefines.CLIENT_NAME)


# TODO: 填充真实逻辑
func place_settlement():
    Log.logd("开始放置定居点...")
    yield(get_tree().create_timer(2), "timeout")
    PlayingNet.rpc("place_settlement_done", _get_name())


# TODO: 填充真实逻辑
func place_road():
    Log.logd("开始放置道路...")
    yield(get_tree().create_timer(2), "timeout")
    PlayingNet.rpc("place_road_done", _get_name())