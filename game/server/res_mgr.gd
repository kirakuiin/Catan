extends Reference

# 资源管理器

var _map: Protocol.MapInfo
var _buildings: Dictionary
var _scores: Dictionary
var _bank: Protocol.BankInfo
var _size: int

var _num_to_res: Dictionary
var _num_to_corner: Dictionary
var _robber_pos: Vector3


func _init(map: Protocol.MapInfo, buildings: Dictionary, scores: Dictionary, catan_size: int, bank: Protocol.BankInfo):
    _map = map
    _buildings = buildings
    _scores = scores
    _size = catan_size
    _bank = bank
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
        var total = Util.sum(_scores[player].res_cards.values())
        if total >= 8:
            discard_infos[player] = total/2
    return discard_infos


# 购买行为
func buy(player_name: String, type: int) -> Dictionary:
    var res_info = Data.OP_DATA[type]
    recycle_player_res(player_name, res_info)
    return res_info


# 银行分配指定资源
func bank_give_res(player_name: String, res_info: Dictionary) -> Dictionary:
    var result = {}
    for res_type in res_info:
        Util.merge_int_dict(result, {res_type: _give_res_to_player(player_name, res_type, res_info[res_type])})
    return result


# 垄断资源
func monopoly_res(player_name: String, res_type: int) -> Dictionary:
    var affect = {player_name: {}}
    for player in _scores:
        if player != player_name:
            var result = _monopoly_from_player(player, res_type)
            if result:
                affect[player] = result
                Util.merge_int_dict(affect[player_name], result)
    Util.merge_int_dict(_scores[player_name].res_cards, affect[player_name])
    return affect

func _monopoly_from_player(player_name: String, res_type: int):
    var cards = _scores[player_name].res_cards
    var result = {}
    if res_type in cards and cards[res_type] != 0:
        result = {res_type: cards[res_type]}
        cards[res_type] = 0
    return result


# 回收玩家资源
func recycle_player_res(player_name: String, recycle_info):
    var res_info = _scores[player_name].res_cards
    for res_type in recycle_info:
        res_info[res_type] -= recycle_info[res_type]
        _modify_capacity(res_type, recycle_info[res_type])


# 抢劫资源
func rob_resource(from: String, to: String) -> bool:
    if from != to and Util.sum(_scores[to].res_cards.values()) > 0:
        _transmit_res_to_player(to, {_random_choice_res(to): 1,}, from)
        return true
    else:
        return false

func _random_choice_res(player: String) -> int:
    var res_cards = _scores[player].res_cards
    var types = []
    for type in res_cards:
        for _i in res_cards[type]:
            types.append(type)
    types.shuffle()
    return types[0]

func _transmit_res_to_player(from: String, res_info: Dictionary, to: String):
    for res_type in res_info:
        var num = res_info[res_type]
        _scores[from].res_cards[res_type] -= num
    Util.merge_int_dict(_scores[to].res_cards, res_info)


# 根据点数分配资源
func dispatch_by_num(num: int) -> Dictionary:
    var affect_player = {}
    for corner in _num_to_corner[num].values():
        for player in _buildings:
            var result = {}
            if corner in _buildings[player].settlement_info:
                Util.merge_int_dict(result, _update_building_res(player, corner, num, 1))
            if corner in _buildings[player].city_info:
                Util.merge_int_dict(result, _update_building_res(player, corner, num, 2))
            if result:
                if player in affect_player:
                    Util.merge_int_dict(affect_player[player], result)
                else:
                    affect_player[player] = result
    return affect_player


# 分配位置相邻的资源
func dispatch_initial_res(player_name: String) -> Dictionary:
    # TODO: 还原初始资源分配
    # var corner_pos = _buildings[player_name].settlement_info[-1]
    # var res_list = _find_corner_res(corner_pos)
    # var result = {}
    # for res in res_list:
    #     var num = _give_res_to_player(player_name, res[0], 1)
    #     Util.dict_add(result, res[0], num)
    var res_list = [[Data.ResourceType.LUMBER, 1], [Data.ResourceType.BRICK, 1], [Data.ResourceType.WOOL, 1], [Data.ResourceType.ORE, 1], [Data.ResourceType.GRAIN, 1]]
    var result = {}
    for res in res_list:
        var num = _give_res_to_player(player_name, res[0], 8)
        Util.dict_add(result, res[0], num)
    return result


func _update_building_res(player: String, corner: Vector3, point: int, unit: int) -> Dictionary:
    var res = _find_corner_res_with_point(corner, point)
    var result = {}
    for res_type in res:
        var num = _give_res_to_player(player, res_type, unit)
        Util.dict_add(result, res_type, num)
    return result

func _find_corner_res_with_point(corner_pos: Vector3, point: int) -> Array:
    var result = []
    var res_list = _find_corner_res(corner_pos)
    for res_tuple in res_list:
        var res_type = res_tuple[0]
        var res_point = res_tuple[1]
        if res_point == point:
            result.append(res_type)
    return result

func _find_corner_res(corner_pos: Vector3) -> Array:
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

func _give_res_to_player(player: String, res_type: int, num: int) -> int:
    var avail_num = min(_bank.res_info[res_type], num)
    _modify_capacity(res_type, -avail_num)
    if not res_type in _scores[player].res_cards:
        _scores[player].res_cards[res_type] = avail_num
    else:
        _scores[player].res_cards[res_type] += avail_num
    return avail_num

func _modify_capacity(res_type: int, num: int):
    _bank.res_info[res_type] += num
    Log.logi("类型[%d]的资源由(%d->%d)" % [res_type, _bank.res_info[res_type]-num, _bank.res_info[res_type]])