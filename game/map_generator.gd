extends Node

# Catan地图生成器

var _setup_info: Protocol.CatanSetupInfo


# 生成地图
func generate(setup: Protocol.CatanSetupInfo) -> Protocol.MapInfo:
    _setup_info = setup
    var map = _generate_hex_grid()
    if setup.is_random_land:
        map = _randomize_grid(map)
    map = _add_resource(map)
    map = _add_point(map)
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
        var center = Hexlib.Hex.new(vec.x, vec.y, vec.z)
        for tile in _generate_small_grid(center).grid_map.values():
            map.add_tile(tile)
    return map


static func _generate_small_grid(center: Hexlib.Hex = Hexlib.Hex.new(0, 0, 0)):
    var map := Protocol.MapInfo.new()
    for hex in Hexlib.get_spiral_ring(center, 3):
        var tile = Protocol.TileInfo.new(hex.to_vector3())
        map.add_tile(tile)
    return map


func _randomize_grid(map: Protocol.MapInfo) -> Protocol.MapInfo:
    return map


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
            Util.swap(count_dict, idx, swap_idx)


func _get_random_type(count_dict: Dictionary):
    randomize()
    var length = len(count_dict)
    var idx = Util.randi_range(0, length)
    var type = count_dict.keys()[idx]
    count_dict[type] -= 1
    if count_dict[type] == 0:
        count_dict.erase(type)
    return type


func _add_point(map: Protocol.MapInfo) -> Protocol.MapInfo:
    var point_data: Dictionary = Data.NUM_DATA[_setup_info.catan_size]["point"].duplicate(true)
    var grids = map.grid_map.values()
    grids.shuffle()
    for tile in grids:
        if tile.tile_type != Data.TileType.DESERT:
            tile.point_type = _get_random_type(point_data.each_num)
    return map
