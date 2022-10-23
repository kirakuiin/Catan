extends Node

# 航海家地图图生成

const ORIGIN: Vector3 = Vector3(0, 0, 0)
const MapFunc: Script = preload("res://game/map/map_func.gd")

var _setup_info: Protocol.CatanSetupInfo
var _map_info: Protocol.MapInfo


func _init(setup_info: Protocol.CatanSetupInfo, map_info: Protocol.MapInfo):
    _setup_info = setup_info
    _map_info = map_info


func generate():
    return _map_info