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
        var content = String(_set.keys()).right(1)
        content = content.left(len(content)-1)
        return '{%s}' % content

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

    # 增加元素
    func add(elem):
        _set[elem] = 1

    # 移除元素
    func discard(elem):
        _set.erase(elem)

    # 并集
    func union(another: Set) -> Set:
        var result := {}
        for elem in another.values():
            result[elem] = 1
        for elem in values():
            result[elem] = 1
        return Set.new(result.keys())

    # 交集
    func intersect(another: Set) -> Set:
        var result = []
        for elem in _set:
            if another.contains(elem):
                result.append(elem)
        return Set.new(result)

    # 差集
    func diff(another: Set) -> Set:
        var result = []
        for elem in _set:
            if not another.contains(elem):
                result.append(elem)
        return Set.new(result)

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
        return _container[0]

    # 获得全部元素
    func values() -> Array:
        return _container

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