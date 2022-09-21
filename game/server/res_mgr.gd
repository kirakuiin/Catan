extends Reference

# 资源管理器

var _map: Protocol.MapInfo
var _buildings: Dictionary
var _scores: Dictionary
var _size: int

var _num_to_res: Dictionary
var _num_to_corner: Dictionary
var _res_capacity: Dictionary


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

func _update_settlement_res(player: String, corner: Vector3, num: int):
    var res = _find_corner_res(corner, num)
    for res_type in res:
        _give_res_to_player(player, res_type, res[res_type])

func _update_city_res(player: String, corner: Vector3, num: int):
    var res = _find_corner_res(corner, num)
    for res_type in res:
        _give_res_to_player(player, res_type, res[res_type]*2)

func _find_corner_res(corner_pos: Vector3, num: int) -> Dictionary:
    var result = {}
    var corner = Hexlib.create_corner(corner_pos)
    var hexs = Hexlib.get_corner_adjacency_hex(corner)
    for hex in hexs:
        var tile = _map.grid_map[hex.to_vector3()]
        if tile.point_type == num:
            var res_type = Data.TILE_RES[tile.tile_type]
            if res_type in result:
                result[res_type] += 1
            else:
                result[res_type] = 1
    return result

func _give_res_to_player(player: String, res_type: int, num):
    var avail_num = min(_res_capacity[res_type], num)
    _res_capacity[res_type] -= avail_num
    if not res_type in _scores[player].res_cards:
        _scores[player].res_cards[res_type] = avail_num
    else:
        _scores[player].res_cards[res_type] += avail_num
    if _res_capacity[res_type] == 0:
        Log.logw("[server] 类型[%d]的资源耗尽" % res_type)