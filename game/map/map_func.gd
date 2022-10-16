extends Reference

# 地图生成公共函数

const ORIGIN: Vector3 = Vector3(0, 0, 0)


# 地块填充器
class TileFiller:
    extends Reference

    var _map: Protocol.MapInfo
    var _count: Dictionary
    var _graph: StdLib.SparseMatrix
    var _order: Array

    func _init(map: Protocol.MapInfo, count: Dictionary, graph: StdLib.SparseMatrix):
        _map = map
        _count = count
        _order = count.keys()
        _graph = graph

    # 填充点位
    func fill_tile():
        _dfs(ORIGIN)

    func _dfs(pos: Vector3):
        if not _set_tile_in_enough(pos, false):
            _set_tile_in_enough(pos, true)
        for neighbor in _graph.get_adjacency_nodes(pos):
            _dfs(neighbor)

    func _set_tile_in_enough(pos: Vector3, is_strict: bool) -> bool:
        _order.shuffle()
        for tile in _order:
            if _count[tile] > 0 and (is_strict or _check_tile(pos, tile)):
                _set_tile_type(pos, tile)
                return true
        return false

    func _set_tile_type(pos: Vector3, tile_type: int):
        _map.grid_map[pos].tile_type = tile_type
        _count[tile_type] -= 1

    func _check_tile(pos: Vector3, tile_type: int) -> bool:
        for neighbor in _get_all_neighbor(pos):
            var this_type = _map.grid_map[neighbor].tile_type
            if this_type != Data.TileType.DESERT and this_type == tile_type:
                return false
        return true

    func _get_all_neighbor(pos: Vector3) -> Array:
        var neighbors = []
        for neighbor in Hexlib.get_hex_adjacency_hex(Hexlib.create_hex(pos)):
            var vec = neighbor.to_vector3()
            if vec in _map.grid_map:
                neighbors.append(vec)
        return neighbors


# 点数填充器
class PointFiller:
    extends Reference

    var _map: Protocol.MapInfo
    var _count: Dictionary
    var _graph: StdLib.SparseMatrix
    var _order: Array

    func _init(map: Protocol.MapInfo, count: Dictionary, graph: StdLib.SparseMatrix):
        _map = map
        _count = count
        _order = count.keys()
        _graph = graph

    # 填充点位
    func fill_point():
        _dfs(ORIGIN)

    func _dfs(pos: Vector3):
        if not _is_desert(pos):
            if not _set_point_in_enough(pos, false):
                _set_point_in_enough(pos, true)
        for neighbor in _graph.get_adjacency_nodes(pos):
            _dfs(neighbor)

    func _set_point_in_enough(pos: Vector3, is_strict: bool) -> bool:
        _order.shuffle()
        for point in _order:
            if _count[point] > 0 and (is_strict or _check_point(pos, point)):
                _set_point_type(pos, point)
                return true
        return false

    func _is_desert(pos: Vector3):
        return _map.grid_map[pos].tile_type == Data.TileType.DESERT

    func _set_point_type(pos: Vector3, point_type: int):
        _map.grid_map[pos].point_type = point_type
        _count[point_type] -= 1

    func _check_point(pos: Vector3, point_type: int) -> bool:
        var neighbors = _get_all_neighbor(pos)
        if point_type in Data.SMALL_POINT:
            for vec_pos in neighbors:
                if _map.grid_map[vec_pos].point_type in Data.SMALL_POINT:
                    return false
        if point_type in Data.BIG_POINT:
            for vec_pos in neighbors:
                if _map.grid_map[vec_pos].point_type in Data.BIG_POINT:
                    return false
        return true

    func _get_all_neighbor(pos: Vector3) -> Array:
        var neighbors = []
        for neighbor in Hexlib.get_hex_adjacency_hex(Hexlib.create_hex(pos)):
            var vec = neighbor.to_vector3()
            if vec in _map.grid_map:
                neighbors.append(vec)
        return neighbors


# 生成单向图
static func build_graph(map: Protocol.MapInfo) -> StdLib.SparseMatrix:
    var graph = StdLib.SparseMatrix.new()
    var queue = StdLib.Queue.new()
    var has_parent = StdLib.Set.new()
    var visited = StdLib.Set.new()
    queue.enqueue(ORIGIN)
    has_parent.add(ORIGIN)
    while not queue.is_empty():
        var node = queue.dequeue()
        visited.add(node)
        for neighbor in get_all_neighbor(map, node, false, true):
            if not visited.contains(neighbor):
                queue.enqueue(neighbor)
            if not has_parent.contains(neighbor):
                graph.add_edge(node, neighbor, 1)
                has_parent.add(neighbor)
    return graph


# 获得所有的邻接点
static func get_all_neighbor(map: Protocol.MapInfo, pos: Vector3, have_ocean: bool=true, to_vec: bool=false) -> Array:
    var neighbors = []
    for neighbor in Hexlib.get_hex_adjacency_hex(Hexlib.create_hex(pos)):
        var vec = neighbor.to_vector3()
        if vec in map.grid_map and (have_ocean or map.grid_map[vec].tile_type != Data.TileType.OCEAN):
            if to_vec:
                neighbors.append(vec)
            else:
                neighbors.append(neighbor)
    return neighbors

