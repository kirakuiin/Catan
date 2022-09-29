extends Node

# Catan地图生成器

const RETRY_TIME: int = 10

var _setup_info: Protocol.CatanSetupInfo


# 生成地图
func generate(setup: Protocol.CatanSetupInfo) -> Protocol.MapInfo:
    _setup_info = setup
    var map: Protocol.MapInfo
    if setup.is_random_land:
        map = _generate_random_grid()
    else:
        map = _generate_hex_grid()
    map = _add_resource_with_check(map)
    map = _add_point_with_check(map)
    map = _add_ocean(map)
    map = _add_harbor(map)
    return map


func _generate_hex_grid() -> Protocol.MapInfo:
    var map: Protocol.MapInfo
    match _setup_info.catan_size:
        Data.CatanSize.BIG:
            map = _generate_big_grid()
        Data.CatanSize.SMALL:
            map = _generate_small_grid()
    return map


static func _generate_big_grid():
    var map := Protocol.MapInfo.new()
    for vec in [Vector3(0, 0, 0), Vector3(1, -1, 0), Vector3(0, -1, 1), Vector3(-1, 0, 1)]:
        var center = Hexlib.create_hex(vec)
        for tile in _generate_small_grid(center).grid_map.values():
            map.add_tile(tile)
    return map


static func _generate_small_grid(center: Hexlib.Hex = Hexlib.Hex.new(0, 0, 0)):
    var map := Protocol.MapInfo.new()
    for hex in Hexlib.get_spiral_ring(center, 3):
        var tile = Protocol.TileInfo.new(hex.to_vector3())
        map.add_tile(tile)
    return map


func _generate_random_grid() -> Protocol.MapInfo:
    var map := Protocol.MapInfo.new()
    map.add_tile(Protocol.TileInfo.new(Vector3(0, 0, 0)))
    for _i in range(Data.NUM_DATA[_setup_info.catan_size]["tile"].total_num-1):
        var hex = _generate_new_hex(map)
        map.add_tile(Protocol.TileInfo.new(hex.to_vector3()))
    return map


func _generate_new_hex(map: Protocol.MapInfo) -> Hexlib.Hex:
    var pos_list = map.grid_map.keys()
    pos_list.shuffle()
    var hex: Hexlib.Hex
    for i in range(len(pos_list)):
        hex = map.grid_map[pos_list[i]].to_hex()
        var neighbor_num = len(_get_all_neighbor(map, hex))
        if neighbor_num < 6:
            hex = _get_rand_unused_hex(map, hex)
            break
    return hex


func _get_all_neighbor(map: Protocol.MapInfo, hex: Hexlib.Hex, have_ocean=true) -> Array:
    var neighbors = []
    for neighbor in Hexlib.get_hex_adjacency_hex(hex):
        var pos = neighbor.to_vector3()
        if pos in map.grid_map and (have_ocean or map.grid_map[pos].tile_type != Data.TileType.OCEAN):
            neighbors.append(neighbor)
    return neighbors


func _get_rand_unused_hex(map: Protocol.MapInfo, hex: Hexlib.Hex) -> Hexlib.Hex:
    var list = _get_unused_hex_list(map, hex)
    return list[Util.randi_range(0, len(list))]


func _get_unused_hex_list(map: Protocol.MapInfo, hex: Hexlib.Hex) -> Array:
    var list = []
    for neighbor in Hexlib.get_hex_adjacency_hex(hex):
        if not neighbor.to_vector3() in map.grid_map:
            list.append(neighbor)
    return list


func _add_resource_with_check(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var times = 0
    while times < RETRY_TIME:
        map = _add_resource(map)
        if not _is_map_cluster(map, funcref(self, "_check_tile")):
            break
        times += 1
    return map


func _check_tile(tiles: Array) -> bool:
    var first_type = tiles.pop_at(0).tile_type
    for tile in tiles:
        if tile.tile_type != first_type:
            return false
    return true

    

# TODO: 分散的资源生成
func _add_resource(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var tile_data: Dictionary = Data.NUM_DATA[_setup_info.catan_size]["tile"].duplicate(true)
    var count_dict: Dictionary = tile_data.each_num
    if _setup_info.is_random_resource:
        _randomize_resource(count_dict)
    var grids = map.grid_map.values()
    grids.shuffle()
    for tile in grids:
        tile.tile_type = _get_random_type(count_dict)
    return map


func _randomize_resource(count_dict: Dictionary):
    var length = len(count_dict)
    for idx in count_dict:
        var swap_idx = count_dict.keys()[Util.randi_range(0, length)]
        if idx != Data.TileType.DESERT and swap_idx != Data.TileType.DESERT:
            StdLib.swap(count_dict, idx, swap_idx)


func _get_random_type(count_dict: Dictionary):
    var length = len(count_dict)
    var idx = Util.randi_range(0, length)
    var type = count_dict.keys()[idx]
    count_dict[type] -= 1
    if count_dict[type] == 0:
        count_dict.erase(type)
    return type


func _add_point_with_check(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var times = 0
    while times < RETRY_TIME:
        map = _add_point(map)
        if not _is_map_cluster(map, funcref(self, "_check_point")):
            break
        times += 1
    return map


func _check_point(tiles: Array) -> bool:
    var low_count = 0
    var high_count = 0
    for tile in tiles:
        if tile.point_type in [Data.PointType.TWO, Data.PointType.TWELVE]:
            low_count += 1
        if tile.point_type in [Data.PointType.SIX, Data.PointType.EIGHT]:
            high_count += 1
    return low_count == 3 or high_count == 3
    

# TODO: 平衡的点数分布
func _add_point(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var point_data: Dictionary = Data.NUM_DATA[_setup_info.catan_size]["point"].duplicate(true)
    var grids = map.grid_map.values()
    grids.shuffle()
    for tile in grids:
        if tile.tile_type != Data.TileType.DESERT:
            tile.point_type = _get_random_type(point_data.each_num)
    return map


func _is_map_cluster(map: Protocol.MapInfo, value_func: FuncRef) -> bool:
    for tile in map.grid_map.values():
        if _is_cluster_by_hex(map, tile.to_hex(), value_func):
            return true
    return false


func _is_cluster_by_hex(map: Protocol.MapInfo, hex: Hexlib.Hex, value_func: FuncRef) -> bool:
    for direction in Hexlib.Directions:
        var cluster := _cluster_to_tile(map, [hex, Hexlib.hex_neighbor(hex, direction), Hexlib.hex_neighbor(hex, (direction+1)%len(Hexlib.Directions))])
        if len(cluster) < 3:
            continue
        if value_func.call_func(cluster):
            return true
    return false


func _cluster_to_tile(map: Protocol.MapInfo, cluster: Array) -> Array:
    var result := []
    for hex in cluster:
        if hex.to_vector3() in map.grid_map:
            result.append(map.grid_map[hex.to_vector3()])
    return result


func _add_ocean(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var ocean_pos := {}
    for tile in map.grid_map.values():
        for hex in _get_unused_hex_list(map, tile.to_hex()):
            ocean_pos[hex.to_vector3()] = true
    for pos in ocean_pos:
        map.add_tile(Protocol.TileInfo.new(pos, Data.TileType.OCEAN))
    return map


func _add_harbor(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var ocean_list = _get_ocean_list(map)
    var split = len(ocean_list) / Data.NUM_DATA[_setup_info.catan_size].harbor.total_num
    var data = Data.NUM_DATA[_setup_info.catan_size]["harbor"].duplicate(true)
    for idx in range(data.total_num):
        map.harbor_list.append(Protocol.HarborInfo.new(ocean_list[idx*split], _get_random_harbor(data.each_num),
                                                        _get_harbor_angle(map, ocean_list[idx*split])))
    return map


func _get_random_harbor(data: Dictionary):
    var length = len(data)
    var idx = Util.randi_range(0, length)
    var type = data.keys()[idx]
    data[type] -= 1
    if data[type] == 0:
        data.erase(type)
    return type


func _get_ocean_list(map: Protocol.MapInfo) -> Array:
    var pos_list = []
    var queue = [_find_first_ocean_tile(map)]
    while queue:
        var tile = queue.pop_front()
        pos_list.append(tile.cube_pos)
        for neighbor in _get_all_neighbor(map, tile.to_hex()):
            var pos = neighbor.to_vector3()
            if not pos in pos_list and map.grid_map[pos].tile_type == Data.TileType.OCEAN:
                queue.append(map.grid_map[pos])
                break
    return pos_list


func _find_first_ocean_tile(map: Protocol.MapInfo):
    var tile_list = map.grid_map.values()
    tile_list.shuffle()
    for tile in tile_list:
        if tile.tile_type == Data.TileType.OCEAN:
            return tile


func _get_harbor_angle(map: Protocol.MapInfo, ocean_pos: Vector3):
    var ocean_hex = map.grid_map[ocean_pos].to_hex()
    var neighbor_list := _get_all_neighbor(map, ocean_hex, false)
    var rand_hex = neighbor_list[Util.randi_range(0, len(neighbor_list))]
    return Hexlib.hex_relative_angle(ocean_hex, rand_hex)