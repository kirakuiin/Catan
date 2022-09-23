extends Reference

# 资源管理器

var _map: Protocol.MapInfo
var _buildings: Dictionary
var _scores: Dictionary
var _size: int

var _num_to_res: Dictionary
var _num_to_corner: Dictionary
var _res_capacity: Dictionary
var _robber_pos: Vector3


func _init(map: Protocol.MapInfo, buildings: Dictionary, scores: Dictionary, catan_size: int):
    _map = map
    _buildings = buildings
    _scores = scores
    _size = catan_size
    _res_capacity = Data.NUM_DATA[_size].resource.each_num.duplicate(true)
    _init_num_corner()


func _init_num_corner():
    _num_to_corner = {}
    for num in Data.POINT_DATA.keys():
        _num_to_corner[num] = StdLib.Set.new()
    for tile in _map.grid_map.values():
        if tile.point_type in _num_to_corner:
            var corners = Hexlib.get_all_corner(Hexlib.create_hex(tile.cube_pos))
            for corner in corners:
                _num_to_corner[tile.point_type].add(corner.to_vector3())


# 设置强盗位置
func set_robber(robber_pos: Vector3):
    _robber_pos = robber_pos


# 获得需要丢弃资源的玩家和需要丢弃的数量
func get_discard_infos() -> Array:
    var discard_infos = {}
    for player in _scores:
        var total = 0
        for num in _scores[player].res_cards.values():
            total += num
        if total >= 8:
            discard_infos[player] = total/2
    return discard_infos


# 根据点数分配资源
func dispatch_by_num(num: int) -> StdLib.Set:
    var affect_player = StdLib.Set.new()
    for corner in _num_to_corner[num].values():
        for player in _buildings:
            if corner in _buildings[player].settlement_info:
                _update_settlement_res(player, corner, num)
                affect_player.add(player)
            if corner in _buildings[player].city_info:
                _update_city_res(player, corner, num)
                affect_player.add(player)
    return affect_player


# 分配位置相邻的资源
func dispatch_initial_res(player_name: String):
    var corner_pos = _buildings[player_name].settlement_info[-1]
    var res_list = _find_corner_res(corner_pos)
    for res in res_list:
        _give_res_to_player(player_name, res[0], 1)


func _update_settlement_res(player: String, corner: Vector3, num: int):
    var res = _find_corner_res_with_num(corner, num)
    for res_type in res:
        _give_res_to_player(player, res_type, 1)

func _update_city_res(player: String, corner: Vector3, num: int):
    var res = _find_corner_res_with_num(corner, num)
    for res_type in res:
        _give_res_to_player(player, res_type, 2)

func _find_corner_res_with_num(corner_pos: Vector3, num: int) -> Array:
    var result = []
    var res_list = _find_corner_res(corner_pos)
    for res_tuple in res_list:
        var res_type = res_tuple[0]
        var res_point = res_tuple[1]
        if res_point == num:
            result.append(res_type)
    return result

func _find_corner_res(corner_pos: Vector3) -> Array:
    assert(_robber_pos, "must initial robber info")
    var result = []
    var corner = Hexlib.create_corner(corner_pos)
    var hexs = _filter_invalid_tile(Hexlib.get_corner_adjacency_hex(corner))
    for pos in hexs:
        var tile = _map.grid_map[pos]
        var res_type = Data.TILE_RES[tile.tile_type]
        result.append([res_type, tile.point_type])
    return result

func _filter_invalid_tile(hexs: Array):
    var result = []
    for hex in hexs:
        var hex_pos = hex.to_vector3()
        var tile = _map.grid_map[hex_pos]
        if hex_pos != _robber_pos and tile.point_type != Data.PointType.ZERO:
            result.append(hex_pos)
    return result

func _give_res_to_player(player: String, res_type: int, num):
    var avail_num = min(_res_capacity[res_type], num)
    _res_capacity[res_type] -= avail_num
    if not res_type in _scores[player].res_cards:
        _scores[player].res_cards[res_type] = avail_num
    else:
        _scores[player].res_cards[res_type] += avail_num
    if _res_capacity[res_type] == 0:
        Log.logw("类型[%d]的资源耗尽" % res_type)