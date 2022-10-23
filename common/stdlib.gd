extends Reference

# 标准库

class_name StdLib


# 集合
class Set:
    extends Reference

    var _set: Dictionary

    func _init(array: Array=[]):
        for elem in array:
            _set[elem] = 1

    func _to_string():
        var content = String(values()).right(1)
        content = content.left(len(content)-1)
        return 'Set(%s)' % content

    # 获得全部元素
    func values() -> Array:
        return _set.keys()

    # 是否相等
    func equals(another: Set) -> bool:
        var self_v = values()
        self_v.sort()
        var ano_v = another.values()
        ano_v.sort()
        return self_v == ano_v

    # 测试包含关系
    func contains(elem) -> bool:
        return elem in _set

    # 返回大小
    func size() -> int:
        return len(_set)

    # 是否为空
    func is_empty() -> bool:
        return size() == 0

    # 增加元素
    func add(elem):
        _set[elem] = 1

    # 移除元素
    func discard(elem):
        _set.erase(elem)
       
    # 复制
    func duplicate() -> Set:
        return Set.new(values())

    # 并集
    func union(another: Set) -> Set:
        var result := {}
        for elem in another.values():
            result[elem] = 1
        for elem in values():
            result[elem] = 1
        return Set.new(result.keys())

    # 原地并集
    func union_inplace(another: Set):
        for elem in another.values():
            _set[elem] = 1

    # 交集
    func intersect(another: Set) -> Set:
        var result = []
        for elem in _set:
            if another.contains(elem):
                result.append(elem)
        return Set.new(result)

    # 就地交集
    func intersect_inplace(another: Set):
        for elem in values():
            if not another.contains(elem):
                discard(elem) 

    # 差集
    func diff(another: Set) -> Set:
        var result = []
        for elem in _set:
            if not another.contains(elem):
                result.append(elem)
        return Set.new(result)

    # 就地差集
    func diff_inplace(another: Set):
        for elem in values():
            if another.contains(elem):
                discard(elem)

    # 目标是否为自己子集
    func is_sub(another: Set) -> bool:
        for elem in another.values():
            if not elem in _set:
                return false
        return true

    # 目标是否为自己的超集
    func is_super(another: Set) -> bool:
        return another.is_sub(self)


# 队列
class Queue:
    extends Reference

    const NO_LIMIT := 0

    var max_len: int
    var _container: Array

    func _init(m_len=NO_LIMIT):
        max_len = m_len
        _container = []

    func _to_string():
        return "Queue(max_len=%d, %s)" % [max_len, str(_container)]

    # 加入队列
    func enqueue(elem):
        _container.push_front(elem)
        if max_len != NO_LIMIT and size() > max_len:
            return dequeue()
        else:
            return null

    # 移出队列
    func dequeue():
        return _container.pop_back()

    # 获得队首元素
    func front():
        return _container.front()

    # 获得队尾元素
    func back():
        return _container.back()

    # 获得全部元素
    func values() -> Array:
        return _container

    # 是否为空
    func is_empty() -> bool:
        return size() == 0

    # 清除全部
    func clear():
        _container.clear()

    # 获得大小
    func size():
        return len(_container)
    
    # 是否满
    func is_full() -> bool:
        return bool(max_len) and size() == max_len


# 简单状态
class SimpleState:
    extends Reference

    # 进入状态
    func enter():
        pass

    # 退出状态
    func exit():
        pass

    # 状态转换
    func to_state(other: SimpleState) -> SimpleState:
        exit()
        other.enter()
        return other


# 稀疏矩阵
class SparseMatrix:
    extends Reference

    var nodes: Set
    var _graph: Dictionary
    var _not_exist
    var root

    func _init(not_exist=null):
        nodes = Set.new()
        _graph = {}
        _not_exist = not_exist

    func _to_string():
        return "SparseMatrix(%s)" % str(_graph)

    # 获得点的全部可达点
    func get_adjacency_nodes(node) -> Array:
        if node in _graph:
            return _graph[node].keys()
        else:
            return []

    # 添加边
    func add_edge(from, to, distance):
        nodes.add(from)
        nodes.add(to)
        if not from in _graph:
            _graph[from] = {}
        _graph[from][to] = distance

    # 获得距离
    func distance(from, to):
        if from in _graph and to in _graph[from]:
            return _graph[from][to]
        else:
            return _not_exist


# 常用函数


# 获取不连通集合
static func get_union_list(matrix: SparseMatrix) -> Array:
    var can_choose = matrix.nodes.duplicate()
    var unions = []
    while not can_choose.is_empty():
        var union = get_union(matrix, can_choose.values()[0])
        can_choose.diff_inplace(union)
        unions.append(union)
    var cluster = []
    for union in unions:
        cluster.append(build_union_matrix(matrix, union))
    return cluster


# 从一点获取联通的集合
static func get_union(matrix: SparseMatrix, point):
    var union = Set.new()
    var visited = Set.new()
    var queue = Queue.new()
    queue.enqueue(point)
    union.add(point)
    while not queue.is_empty():
        var begin = queue.dequeue()
        visited.add(begin)
        for end in matrix.get_adjacency_nodes(begin):
            union.add(end)
            if not visited.contains(end):
                queue.enqueue(end)
    return union


# 根据集合构建联通矩阵
static func build_union_matrix(matrix: SparseMatrix, union: Set) -> SparseMatrix:
    var result = SparseMatrix.new()
    for node in union.values():
        for end in matrix.get_adjacency_nodes(node):
            if union.contains(end):
                result.add_edge(node, end, 1)
                result.add_edge(end, node, 1)
    return result


# 合并数值字典
static func num_dict_merge(dict_a: Dictionary, dict_b: Dictionary, is_add: bool=true):
    for k in dict_b:
        if is_add:
            num_dict_add(dict_a, k, dict_b[k])
        else:
            num_dict_add(dict_a, k, -dict_b[k])


# 数值字典默认累加
static func num_dict_add(dict: Dictionary, key, value):
    if key in dict:
        dict[key] += value
    else:
        dict[key] = value


# 字典默认获取值
static func dict_get(dict: Dictionary, key, default=null):
    if key in dict:
        return dict[key]
    else:
        return default

# 求和
static func sum(list: Array):
    var total = 0
    for num in list:
        total += num
    return total


# 字典转数组
static func dict_to_array(dict: Dictionary) -> Array:
    var result = []
    for key in dict:
        result.append([key, dict[key]])
    return result


# 交换两个元素
static func swap(container, idx_a, idx_b):
    var var_a = container[idx_a]
    var var_b = container[idx_b]
    container[idx_a] = var_b
    container[idx_b] = var_a


# 位移元素
static func shift_right(array: Array, num: int) -> Array:
    if not array:
        return array
    var result = array
    while num > 0:
        result.push_front(result.pop_back())
        num -= 1
    while num < 0:
        result.push_back(result.pop_front())
        num += 1
    return result