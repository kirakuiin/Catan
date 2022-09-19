extends Node

# 通用功能

class_name Util


# 交换两个元素
static func swap(container, idx_a, idx_b):
    var var_a = container[idx_a]
    var var_b = container[idx_b]
    container[idx_a] = var_b
    container[idx_b] = var_a


# 整数范围随机[from, to)
static func randi_range(from: int, to: int):
    return randi() % (to-from) + from


# 以中心为坐标设置对象位置
static func set_center(obj: Node, pos: Vector2):
    var size = obj.rect_size
    obj.rect_position = Vector2(pos.x-size.x/2, pos.y-size.y/2)


# 获得项目屏幕尺寸
static func get_windows_size() -> Vector2:
    return Vector2(ProjectSettings.get_setting("display/window/size/width"),
                        ProjectSettings.get_setting("display/window/size/height"))
