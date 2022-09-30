extends Reference

# 建筑管理器

var _map: Protocol.MapInfo
var _buildings: Dictionary
var _cards: Dictionary
var _size: int
var _robber_pos: Vector3

var _point_info: StdLib.Set


func _init(map: Protocol.MapInfo, buildings: Dictionary, cards: Dictionary, catan_size: int):
    _map = map
    _buildings = buildings
    _cards = cards
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


# 获得布置阶段所有的可放置点位
func get_setup_available_point() -> Array:
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
    var all_used_point := StdLib.Set.new()
    for building in _buildings.values():
        all_used_point.union_inplace(building.get_settlement_and_city())
    return all_used_point


# 获得布置阶段所有的可放置道路
func get_setup_available_road() -> Array:
    var result = []
    var roads = _get_road_tuple_from_corner(_buildings[_get_name()].settlement_info[-1])
    for tuple in roads.values():
        result.append(Protocol.create_road(tuple))
    return result

func _get_road_tuple_from_corner(pos: Vector3) -> StdLib.Set:
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
    var possible_roads = _get_player_possible_road(_get_name())
    var exist_roads = _get_exist_tuple_roads()
    var result = []
    for tuple in possible_roads.values():
        if not exist_roads.contains(tuple) and not _is_fly_road(tuple):
            result.append(Protocol.create_road(tuple))
    return result

func _get_player_possible_road(player: String) -> StdLib.Set:
    var road_set = StdLib.Set.new()
    var corner_set = _buildings[player].get_all_road_point()
    for corner in corner_set.values():
        road_set.union_inplace(_get_road_tuple_from_corner(corner))
    return road_set

func _get_exist_tuple_roads() -> StdLib.Set:
    var result = StdLib.Set.new()
    for player in _buildings:
        for road in _buildings[player].road_info:
            result.add(road.to_tuple())
    return result

func _is_fly_road(tuple: Array) -> bool:
    var all_corner = _buildings[_get_name()].get_all_road_point()
    var self_corner = tuple[0] if all_corner.contains(tuple[0]) else tuple[1]
    var other_building_corner = StdLib.Set.new()
    for player in _buildings:
        if player != _get_name():
            other_building_corner.union_inplace(_buildings[player].get_settlement_and_city())
    return other_building_corner.contains(self_corner)


# 获得布置阶段所有的可放置点位
func get_turn_available_point() -> Array:
    var player_corner = _buildings[_get_name()].get_all_road_point()
    var avail_point = StdLib.Set.new(get_setup_available_point())
    avail_point.intersect_inplace(player_corner)
    return avail_point.values()


# 获得可升级的点位
func get_avail_upgrade_point() -> Array:
    var result = []
    for settlement in _buildings[_get_name()].settlement_info:
        result.append(settlement)
    return result


# 获得某个地块所有玩家的建筑位置
func get_tile_player_building(pos: Vector3) -> Dictionary:
    var result = {}
    var hex = Hexlib.create_hex(pos)
    for corner in Hexlib.get_all_corner(hex):
        for player in _buildings:
            var corner_pos = corner.to_vector3()
            if _buildings[player].get_settlement_and_city().contains(corner_pos):
                if player in result:
                    result[player].append(corner_pos)
                else:
                    result[player] = [corner_pos]
                break
    return result


func _get_name() -> String:
    return PlayerInfoMgr.get_self_info().player_name