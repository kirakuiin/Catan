extends Node

# 航海家地图图生成

const ORIGIN: Vector3 = Vector3(0, 0, 0)
const MapFunc: Script = preload("res://game/map/map_func.gd")

var _setup_info: Protocol.CatanSetupInfo


func _init(setup_info: Protocol.CatanSetupInfo):
    _setup_info = setup_info


func generate() -> Protocol.MapInfo:
    return Protocol.MapInfo.new()
