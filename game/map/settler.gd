extends Node

# 标准版地图生成

const RETRY_TIME: int = 50
const ORIGIN: Vector3 = Vector3(0, 0, 0)
const MapFunc: Script = preload("res://game/map/map_func.gd")

var _setup_info: Protocol.CatanSetupInfo
var _map_info: Protocol.MapInfo


func _init(setup_info: Protocol.CatanSetupInfo, map_info: Protocol.MapInfo):
    _setup_info = setup_info
    _map_info = map_info


# 生成地图
func generate():
    if _map_info.tile_average:
        _add_tile_with_average()
    else:
        _add_tile()
    _fill_fix_tile()
    if _map_info.point_average:
        _add_point_with_check()
    else:
        _add_point()
    _fill_fix_point()
    _add_harbor()


func _add_tile_with_average():
    var times = 0
    while times < RETRY_TIME:
        _add_tile()
        if not _is_map_cluster(funcref(self, "_check_tile")):
            break
        times += 1


func _is_map_cluster(value_func: FuncRef) -> bool:
    for tile in _map_info.tile_map.values():
        if _is_cluster_by_hex(tile.to_hex(), value_func):
            return true
    return false

func _is_cluster_by_hex(hex: Hexlib.Hex, value_func: FuncRef) -> bool:
    for direction in Hexlib.Directions:
        var cluster := _cluster_to_tile([hex, Hexlib.hex_neighbor(hex, direction), Hexlib.hex_neighbor(hex, (direction+1)%len(Hexlib.Directions))])
        if value_func.call_func(cluster):
            return true
    return false

func _cluster_to_tile(cluster: Array) -> Array:
    var result := []
    for hex in cluster:
        if hex.to_vector3() in _map_info.tile_map:
            result.append(_map_info.tile_map[hex.to_vector3()])
    return result

func _check_tile(tiles: Array) -> bool:
    var first_type = tiles.pop_at(0).tile_type
    for tile in tiles:
        if tile.tile_type == first_type:
            return true
    return false


func _add_tile() -> Protocol.MapInfo:
    var tile_data = _map_info.tile_pool.duplicate(true)
    if _setup_info.is_random_resource:
        _randomize_resource(tile_data)
    _map_info.clear_generate_tile()
    var filler = MapFunc.TileFiller.new(_map_info, tile_data, MapFunc.build_graph(_map_info.get_uncertain_tiles()))
    filler.fill_tile()
    return _map_info


func _randomize_resource(count_dict: Dictionary):
    var length = len(count_dict)
    for idx in count_dict:
        var swap_idx = count_dict.keys()[Util.randi_range(0, length)]
        if idx != Data.TileType.DESERT and swap_idx != Data.TileType.DESERT:
            StdLib.swap(count_dict, idx, swap_idx)


func _add_point_with_check():
    var times = 0
    while times < RETRY_TIME:
        _add_point()
        if not _is_map_cluster(funcref(self, "_check_point")):
            break
        times += 1

func _check_point(tiles: Array) -> bool:
    var low_count = 0
    var high_count = 0
    for tile in tiles:
        if Data.is_small_point(tile.point_type):
            low_count += 1
        if Data.is_big_point(tile.point_type):
            high_count += 1
    return low_count > 1 or high_count > 1
    

func _add_point():
    var point_data = _map_info.point_pool.duplicate(true)
    _map_info.clear_generate_point()
    var filler = MapFunc.PointFiller.new(_map_info, point_data, MapFunc.build_graph(_map_info.get_uncertain_points()))
    filler.fill_point()


func _fill_fix_tile():
    for tile in _map_info.origin_tiles.values():
        if tile.tile_type != Data.TileType.RANDOM:
            _map_info.tile_map[tile.cube_pos] = Protocol.copy(tile)

func _fill_fix_point():
    for tile in _map_info.origin_tiles.values():
        if tile.point_type != Data.PointType.RANDOM:
            _map_info.tile_map[tile.cube_pos].point_type = tile.point_type


func _add_harbor():
    var harbor_pool = _map_info.harbor_pool.duplicate(true)
    for harbor_info in _map_info.get_uncertain_harbors():
        var new_info = Protocol.copy(harbor_info)
        new_info.harbor_type = _get_random_harbor(harbor_pool)
        _map_info.harbor_list.append(new_info)

    for harbor_info in _map_info.origin_harbors:
        if harbor_info.harbor_type != Data.HarborType.RANDOM:
            _map_info.harbor_list.append(Protocol.copy(harbor_info))


func _get_random_harbor(data: Dictionary):
    for key in data.keys():
        if data[key] <= 0:
            data.erase(key)
    var length = len(data)
    var idx = Util.randi_range(0, length)
    var type = data.keys()[idx]
    data[type] -= 1
    if data[type] == 0:
        data.erase(type)
    return type