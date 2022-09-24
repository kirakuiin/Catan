extends Reference

# 建筑管理器

var _map: Protocol.MapInfo
var _buildings: Dictionary
var _scores: Dictionary
var _size: int

var _point_info: StdLib.Set


func _init(map: Protocol.MapInfo, buildings: Dictionary, scores: Dictionary, catan_size: int):
    _map = map
    _buildings = buildings
    _scores = scores
    _size = catan_size
    _init_point_info()

func _init_point_info():
    _point_info = StdLib.Set.new()
    for tile_info in _map.grid_map.values():
        if tile_info.tile_type != Data.TileType.OCEAN:
            var hex = tile_info.to_hex()
            for corner in Hexlib.get_all_corner(hex):
                _point_info.add(corner.to_vector3())


# 返回提示点位信息
func get_point_info() -> StdLib.Set:
    return _point_info


# 获得所有的可放置点位
func get_available_point() -> Array:
    var result = []
    var all_used_point = _get_all_used_point()
    var not_used_point = _point_info.diff(all_used_point)
    for point in not_used_point.values():
        var neighbor = StdLib.Set.new()
        var corners = Hexlib.get_adjacency_corner(Hexlib.create_corner(point))
        for corner in corners:
            neighbor.add(corner.to_vector3())
        if neighbor.intersect(all_used_point).size() == 0:
            result.append(point)
    return result

func _get_all_used_point() -> StdLib.Set:
    var all_used_point := []
    for building in _buildings.values():
        all_used_point.append_array(building.settlement_info)
        all_used_point.append_array(building.city_info)
    return StdLib.Set.new(all_used_point)


# 获得布置阶段所有的可放置道路
func get_setup_available_road() -> Array:
    var result = []
    var roads = _get_road_from_corner(_buildings[PlayerInfoMgr.get_self_info().player_name].settlement_info[-1])
    for tuple in roads.values():
        result.append(Protocol.create_road(tuple))
    return result

func _get_road_from_corner(pos: Vector3) -> StdLib.Set:
        var result = StdLib.Set.new()
        var begin = Hexlib.create_corner(pos)
        for end in Hexlib.get_adjacency_corner(begin):
            if _is_valid_land_corner(end):
                result.add(Protocol.RoadInfo.new(begin.to_vector3(), end.to_vector3()).to_tuple())
        return result

func _is_valid_land_corner(corner: Hexlib.Corner) -> bool:
    for hex in Hexlib.get_corner_adjacency_hex(corner):
        var cube_pos = hex.to_vector3()
        if cube_pos in _map.grid_map and _map.grid_map[cube_pos].tile_type != Data.TileType.OCEAN:
            return true
    return false


# 获得回合阶段所有的可放置道路
func get_turn_available_road() -> Array:
    var result = []
    return result