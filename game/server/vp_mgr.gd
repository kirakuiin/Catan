extends Reference

# 胜点管理器


var _cards: Dictionary
var _buildings: Dictionary
var _personals: Dictionary
var _assist: Protocol.AssistInfo


func _init(cards: Dictionary, buildings: Dictionary, personals: Dictionary, assist_info: Protocol.AssistInfo):
    _cards = cards
    _buildings = buildings
    _personals = personals
    _assist = assist_info


# 成就记录
class Archievement:
    extends Reference

    var old_holder: String=""
    var new_holder: String=""


# 更新军队成就
func update_army(player_name: String) -> Archievement:
    var arch = Archievement.new()
    if _personals[player_name].army_num < 3:
        return arch
    if not _assist.biggest_name:
        _assist.biggest_name = player_name
        arch.new_holder = player_name
        update_vp(player_name)
    elif _personals[_assist.biggest_name].army_num < _personals[player_name].army_num:
        arch.old_holder = _assist.biggest_name
        arch.new_holder = player_name
        _assist.biggest_name = player_name
        update_vp(arch.old_holder)
        update_vp(arch.new_holder)
    return arch


# 更新道路成就
func update_road(player_name: String) -> Archievement:
    var arch = Archievement.new()
    _calc_continue_road(player_name)
    return arch


# 更新玩家分数
func update_vp(player_name: String):
    var vp := 0
    var building = _buildings[player_name]
    vp += len(building.settlement_info)
    vp += len(building.city_info)*2
    vp += StdLib.dict_get(_cards[player_name].dev_cards, Data.CardType.VP, 0)
    if _assist.longgest_name == player_name:
        vp += 2
    if _assist.biggest_name == player_name:
        vp += 2
    _personals[player_name].vic_point = vp


# 计算最长连续道路
func _calc_continue_road(player_name: String):
    pass
    #var matrix = _build_road_matrix(player_name)
    


func _build_road_matrix(player_name: String) -> StdLib.SparseMatrix:
    var matrix = StdLib.SparseMatrix.new(-INF)
    for road in _buildings[player_name].road_info:
        matrix.add_edge(road.begin_node, road.end_node, 1)
        matrix.add_edge(road.end_node, road.begin_node, 1)
    return matrix