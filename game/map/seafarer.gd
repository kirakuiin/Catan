extends Node

# 航海家地图图生成

const ORIGIN: Vector3 = Vector3(0, 0, 0)
const MapFunc: Script = preload("res://game/map/map_func.gd")

var _setup_info: Protocol.CatanSetupInfo


func _init(setup_info: Protocol.CatanSetupInfo):
    _setup_info = setup_info


func generate() -> Protocol.MapInfo:
    var map_data = _get_map_data()
    var result = Protocol.MapInfo.new()
    for pos in map_data.main:
        result.add_tile(Protocol.TileInfo.new(pos))
    for pos in map_data.island:
        result.add_tile(Protocol.TileInfo.new(pos))
    return result


func _fill_small_map(center: Vector3) -> Array:
    var result = []
    for hex in Hexlib.get_spiral_ring(Hexlib.create_hex(center), 3):
        result.append('Vector3%s' % hex.to_vector3())
    return result


func _fill_big_map() -> Array:
    var result = StdLib.Set.new()
    for vec in [ORIGIN, Vector3(1, -1, 0), Vector3(0, -1, 1), Vector3(-1, 0, 1)]:
        result.union_inplace(StdLib.Set.new(_fill_small_map(vec)))
    return result.values()

   
func _get_map_data():
    return MapData.MAP_DATA[_setup_info.catan_size][_setup_info.expansion_mode.selected_map]