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
    # TODO: 考虑放置定居点时可能截断他人道路
    _get_all_cluster(player_name)

func _get_all_cluster(player_name: String):
    var matrix = _build_road_matrix(player_name)
    var all_other = _get_all_other_point(player_name)
    var can_choose = matrix.nodes.diff(all_other)
    var unions = []
    while not can_choose.is_empty():
        var union = _get_union(all_other, matrix, can_choose.values()[0])
        can_choose.diff_inplace(union)
        unions.append(union)
    var cluster = []
    for union in unions:
        cluster.append(_build_union_matrix(matrix, union))
    Log.logd("[%s] cluster = %s" % [player_name, str(cluster)])
    return cluster

func _build_road_matrix(player_name: String) -> StdLib.SparseMatrix:
    var matrix = StdLib.SparseMatrix.new(-INF)
    for road in _buildings[player_name].road_info:
        matrix.add_edge(road.begin_node, road.end_node, 1)
        matrix.add_edge(road.end_node, road.begin_node, 1)
    return matrix

func _get_all_other_point(player_name: String) -> StdLib.Set:
    var result = StdLib.Set.new()
    for player in _buildings:
        if player != player_name:
            result.union_inplace(_buildings[player].get_settlement_and_city())
    return result

func _get_union(other_player_point: StdLib.Set, matrix: StdLib.SparseMatrix, point: Vector3) -> StdLib.Set:
    var union = StdLib.Set.new()
    var visited = StdLib.Set.new()
    var queue = StdLib.Queue.new()
    queue.enqueue(point)
    union.add(point)
    while not queue.is_empty():
        var begin = queue.dequeue()
        visited.add(begin)
        for end in matrix.get_adjacency_nodes(begin):
            union.add(end)
            if not other_player_point.contains(end) and not visited.contains(end):
                queue.enqueue(end)
    return union

func _build_union_matrix(matrix: StdLib.SparseMatrix, union: StdLib.Set) -> StdLib.SparseMatrix:
    var result = StdLib.SparseMatrix.new()
    for node in union.values():
        for end in matrix.get_adjacency_nodes(node):
            if union.contains(end):
                result.add_edge(node, end, 1)
                result.add_edge(end, node, 1)
    return result

func _dfs(node, matrix: StdLib.SparseMatrix, length: int, visited: StdLib.Set, max_array: Array):
    for end in matrix.get_adjacency_nodes(node):
        if visited.contains([node, end]):
            continue
        visited.add([node, end])
        visited.add([end, node])
        _dfs(end, matrix, length+1, visited, max_array)
        visited.discard([node, end])
        visited.discard([end, node])