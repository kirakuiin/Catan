extends Node


# 游戏中客户端


func _init():
    pass


func _ready():
    _init_node_setup()
    PlayingNet.rpc("client_ready", PlayerInfoMgr.get_self_info().player_name)


func _init_node_setup():
    name = NetDefines.CLIENT_NAME
    add_to_group(NetDefines.CLIENT_NAME)