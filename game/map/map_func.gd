extends Reference

# 地图生成公共函数


# 地块填充器
class TileFiller:
    extends Reference

    var _map: Protocol.MapInfo
    var _count: Dictionary
    var _graphs: Array
    var _order: Array

    func _init(map: Protocol.MapInfo, count: Dictionary, graphs: Array):
        _map = map
        _count = count
        _order = count.keys()
        _graphs = graphs

    # 填充点位
    func fill_tile():
        for graph in _graphs:
            _dfs(graph.root, graph)

    func _dfs(pos: Vector3, graph: StdLib.SparseMatrix):
        if not _set_tile_in_enough(pos, false):
            _set_tile_in_enough(pos, true)
        for neighbor in graph.get_adjacency_nodes(pos):
            _dfs(neighbor, graph)

    func _set_tile_in_enough(pos: Vector3, is_strict: bool) -> bool:
        _order.shuffle()
        for tile in _order:
            if _count[tile] > 0 and (is_strict or _check_tile(pos, tile)):
                _set_tile_type(pos, tile)
                return true
        return false

    func _set_tile_type(pos: Vector3, tile_type: int):
        _map.tile_map[pos] = Protocol.TileInfo.new(pos, tile_type, Data.PointType.ZERO, _map.origin_tiles[pos].tile_form)
        _count[tile_type] -= 1

    func _check_tile(pos: Vector3, tile_type: int) -> bool:
        for neighbor in _get_all_neighbor(pos):
            var this_type = _map.tile_map[neighbor].tile_type
            if this_type == tile_type:
                return false
        return true

    func _get_all_neighbor(pos: Vector3) -> Array:
        var neighbors = []
        for neighbor in Hexlib.get_hex_adjacency_hex(Hexlib.create_hex(pos)):
            var vec = neighbor.to_vector3()
            if vec in _map.tile_map:
                neighbors.append(vec)
        return neighbors


# 点数填充器
class PointFiller:
    extends Reference

    var _map: Protocol.MapInfo
    var _count: Dictionary
    var _graphs: Array
    var _order: Array

    func _init(map: Protocol.MapInfo, count: Dictionary, graphs: Array):
        _map = map
        _count = count
        _order = count.keys()
        _graphs = graphs

    # 填充点位
    func fill_point():
        for graph in _graphs:
            _dfs(graph.root, graph)

    func _dfs(pos: Vector3, graph: StdLib.SparseMatrix):
        if not _is_desert(pos):
            if not _set_point_in_enough(pos, false):
                _set_point_in_enough(pos, true)
        for neighbor in graph.get_adjacency_nodes(pos):
            _dfs(neighbor, graph)

    func _set_point_in_enough(pos: Vector3, is_strict: bool) -> bool:
        _order.shuffle()
        for point in _order:
            if _count[point] > 0 and (is_strict or _check_point(pos, point)):
                _set_point_type(pos, point)
                return true
        return false

    func _is_desert(pos: Vector3):
        return _map.tile_map[pos].tile_type == Data.TileType.DESERT

    func _set_point_type(pos: Vector3, point_type: int):
        _map.tile_map[pos].point_type = point_type
        _count[point_type] -= 1

    func _check_point(pos: Vector3, point_type: int) -> bool:
        var neighbors = _get_all_neighbor(pos)
        if Data.is_small_point(point_type):
            for vec_pos in neighbors:
                if Data.is_small_point(_map.tile_map[vec_pos].point_type):
                    return false
        if Data.is_big_point(point_type):
            for vec_pos in neighbors:
                if Data.is_big_point(_map.tile_map[vec_pos].point_type):
                    return false
        return true

    func _get_all_neighbor(pos: Vector3) -> Array:
        var neighbors = []
        for neighbor in Hexlib.get_hex_adjacency_hex(Hexlib.create_hex(pos)):
            var vec = neighbor.to_vector3()
            if vec in _map.tile_map:
                neighbors.append(vec)
        return neighbors


# 生成单向图
static func build_graph(uncertain_tile: Dictionary) -> Array:
    var map = StdLib.Set.new(uncertain_tile.keys())
    var result = []
    while not map.is_empty():
        var node = map.values()[0]
        var queue = StdLib.Queue.new()
        var sparse = StdLib.SparseMatrix.new()
        var visited = StdLib.Set.new()
        var has_parent = StdLib.Set.new()
        sparse.root = node
        queue.enqueue(node)
        has_parent.add(node)
        while not queue.is_empty():
            var elem = queue.dequeue()
            visited.add(elem)
            for neighbor in get_all_neighbor(uncertain_tile, elem):
                if not visited.contains(neighbor):
                    queue.enqueue(neighbor)
                if not has_parent.contains(neighbor):
                    sparse.add_edge(elem, neighbor, 1)
                    has_parent.add(neighbor)
            map.diff_inplace(StdLib.Set.new([elem]))
        result.append(sparse)
    return result


# 获得所有的邻接点
static func get_all_neighbor(map: Dictionary, pos: Vector3) -> Array:
    var neighbors = []
    for neighbor in Hexlib.get_hex_adjacency_hex(Hexlib.create_hex(pos)):
        var vec = neighbor.to_vector3()
        if vec in map:
            neighbors.append(vec)
    return neighbors

