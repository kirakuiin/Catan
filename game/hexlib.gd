extends Node

# 六边形库

class_name Hexlib

# 代表六边形网格中的一个六边形的位置
class Hex:
    extends Reference
    
    var q: int
    var r: int
    var s: int

    func _init(var_q: int=0, var_r: int=0, var_s:int =0):
        q = var_q
        r = var_r
        s = var_s
        assert(q+r+s == 0, "六边形坐标总和必须为0")

    func _to_string():
        return '{0}({1}, {2}, {3})'.format(["Hex", q, r, s])

    func to_vector3() -> Vector3:
        return Vector3(q, r, s)

    func from_vector3(vec: Vector3):
        q = vec.x as int
        r = vec.y as int
        s = vec.z as int
        assert(q+r+s == 0, "六边形坐标总和必须为0")



# 代表六边形网格中的一个六边形的顶点
class Corner:
    extends Reference

    const TYPE_POSITIVE: int = 1  # 总和为1
    const TYPE_NEGATIVE: int = -1  # 总和为-1

    var q: int
    var r: int
    var s: int

    func _init(var_q: int, var_r: int, var_s: int):
        q = var_q
        r = var_r
        s = var_s
        assert(abs(q+r+s) == 1, '顶点坐标总和绝对值必须为1')

    func _to_string() -> String:
        return '{0}({1}, {2}, {3})'.format(["Corner", self.q, self.r, self.s])

    func get_type() -> int:
        return TYPE_POSITIVE if q+r+s == 1 else TYPE_NEGATIVE


# 朝向, fx代表变换矩阵, bx代表逆矩阵
class Orientation:
    extends Reference

    # 矩阵
    var f0: float
    var f1: float
    var f2: float
    var f3: float
    # 逆矩阵
    var b0: float
    var b1: float
    var b2: float
    var b3: float
    var start_angle: float

    func _init(fa, fb, fc, fd, ba, bb, bc, bd, angle):
        f0 = fa
        f1 = fb
        f2 = fc
        f3 = fd
        b0 = ba
        b1 = bb
        b2 = bc
        b3 = bd
        start_angle = angle


# 决定hex坐标转换所使用的参数
class HexLayout:
    extends Reference

    var orientation: Orientation
    var size: Vector2
    var origin: Vector2

    func _init(ori, v_size=Vector2(20, 20), v_origin=Vector2(0, 0)):
        orientation = ori
        size = v_size
        origin = v_origin


# 尖顶方向
enum PointyDirection {EAST=0, NORTHEAST=1, NORTHWEST=2, WEST=3, SOUTHWEST=4, SOUTHEAST=5}


# 平顶方向
enum FlatDirection {SOUTHEAST=0, NORTHEAST=1, NORTH=2, NORTHWEST=3, SOUTHWEST=4, SOUTH=5}


# 方向列表
const Directions = [0, 1, 2, 3, 4, 5]


# 尖顶六边形
static func Pointy() -> Orientation:
    return Orientation.new(sqrt(3), sqrt(3)/2, 0.0, 1.5, sqrt(3)/3, -1.0/3, 0.0, 2.0/3, -30)


# 平顶六边形
static func Flat() -> Orientation:
    return Orientation.new(1.5, 0.0, sqrt(3.0)/2, sqrt(3), 2.0/3, 0.0, -1.0/3, sqrt(3)/3, 0)


# 默认layout
static func Layout() -> HexLayout:
    return HexLayout.new(Flat())


static func hex_equal(hex_a: Hex, hex_b: Hex) -> bool:
    return hex_a.q == hex_b.q and hex_a.r == hex_b.r and hex_a.s == hex_b.s


static func hex_add(hex_a: Hex, hex_b: Hex) -> Hex:
    return Hex.new(hex_a.q+hex_b.q, hex_a.r+hex_b.r, hex_a.s+hex_b.s)


static func hex_sub(hex_a: Hex, hex_b: Hex) -> Hex:
    return Hex.new(hex_a.q-hex_b.q, hex_a.r-hex_b.r, hex_a.s-hex_b.s)


static func hex_mul(hex: Hex, k: int) -> Hex:
    return Hex.new(hex.q*k, hex.r*k, hex.s*k)


static func hex_distance(hex_a: Hex, hex_b: Hex) -> int:
    var new_hex = hex_sub(hex_a, hex_b)
    return int((abs(new_hex.q) + abs(new_hex.r) + abs(new_hex.s)) / 2)


static func hex_direction(direction: int) -> Hex:
    assert(direction >= 0 and direction < 6, "六边形方向无效")
    var dir_list = [Hex.new(1, 0, -1), Hex.new(1, -1, -0), Hex.new(0, -1, 1),
                        Hex.new(-1, 0, 1), Hex.new(-1, 1, 0), Hex.new(0, 1, -1)]
    return dir_list[direction]


static func hex_neighbor(hex: Hex, direction: int) -> Hex:
    return hex_add(hex, hex_direction(direction))


static func corner_equal(corner_a: Corner, corner_b: Corner) -> bool:
    return corner_a.q == corner_b.q and corner_a.r == corner_b.r and corner_a.s == corner_b.s


# 获得邻接的六个六边形
static func get_hex_adjacency_hex(hex: Hex) -> Array:
    var result = []
    for direction in Directions:
        result.append(hex_neighbor(hex, direction))
    return result


# 获得邻接的三个六边形
static func get_corner_adjacency_hex(corner: Corner) -> Array:
    if corner.get_type() == Corner.TYPE_POSITIVE:
        return [Hex.new(corner.q, corner.r, corner.s-1), Hex.new(corner.q-1, corner.r, corner.s), Hex.new(corner.q, corner.r-1, corner.s)]
    else:
        return [Hex.new(corner.q+1, corner.r, corner.s), Hex.new(corner.q, corner.r+1, corner.s), Hex.new(corner.q, corner.r, corner.s+1)]


# 获得邻接的三个顶点
static func get_adjacency_corner(corner: Corner) -> Array:
    if corner.get_type() == Corner.TYPE_POSITIVE:
        return [Corner.new(corner.q, corner.r-1, corner.s-1),
                    Corner.new(corner.q-1, corner.r-1, corner.s), Corner.new(corner.q-1, corner.r, corner.s-1)]
    else:
        return [Corner.new(corner.q+1, corner.r+1, corner.s), Corner.new(corner.q+1, corner.r, corner.s+1),
                    Corner.new(corner.q, corner.r+1, corner.s+1)]


# 得到六个角, 以0°(Flat)或30°(Pointy)的角作为起点, 顺时针
static func get_all_corner(hex: Hex) -> Array:
    return [Corner.new(hex.q+1, hex.r, hex.s), Corner.new(hex.q, hex.r-1, hex.s), Corner.new(hex.q, hex.r, hex.s+1),
                Corner.new(hex.q-1, hex.r, hex.s), Corner.new(hex.q, hex.r+1, hex.s), Corner.new(hex.q, hex.r, hex.s-1)]


# 构建六边形环
static func get_ring(center: Hex, radius: int) -> Array:
    assert(radius > 0, "环的半径必须大于0")
    var result = []
    var hex = hex_add(center, hex_mul(hex_direction(PointyDirection.SOUTHWEST), radius))
    for dir in Directions:
        for _j in range(radius):
            hex = hex_neighbor(hex, dir)
            result.append(hex)
    return result


# 生成螺旋
static func get_spiral_ring(center: Hex, radius: int) -> Array:
    var result = [center]
    for r in range(1, radius):
        result.append_array(get_ring(center, r))
    return result


# 判断顶点在六边形中的索引位置, 不存在则返回-1
static func get_corner_index(hex: Hex, corner: Corner) -> int:
    var list = get_all_corner(hex)
    for cor in list:
        if corner_equal(cor, corner):
            return list.find(cor)
    return -1


# 判断顶点是否属于六边形
static func is_hex_corner(hex: Hex, corner: Corner) -> bool:
    for hex_cor in hex.get_all_corner():
        if corner_equal(hex_cor, corner):
            return true
    return false


# 两个六边形之间的相对角度
static func hex_relative_angle(hex_a: Hex, hex_b: Hex, layout: HexLayout = Layout()) -> float:
    var center_a = hex_to_pixel(layout, hex_a)
    var center_b = hex_to_pixel(layout, hex_b)
    var diff = center_b-center_a
    return rad2deg(atan2(diff.y, diff.x))


# 将网格坐标转换为屏幕坐标
static func hex_to_pixel(layout: HexLayout, coord: Hex) -> Vector2:
    var matrix = layout.orientation
    var x = (matrix.f0 * coord.q + matrix.f1 * coord.r) * layout.size.x
    var y = (matrix.f2 * coord.q + matrix.f3 * coord.r) * layout.size.y
    return Vector2(x, y) + layout.origin


# 将顶点坐标转化为屏幕坐标
static func corner_to_pixel(layout: HexLayout, coord: Corner):
    var base_hex = get_corner_adjacency_hex(coord)[0]
    var index = get_corner_index(base_hex, coord)
    var angle = deg2rad(layout.orientation.start_angle - index*60)
    var offset = Vector2(layout.size.x*cos(angle), layout.size.y*sin(angle))
    var center = hex_to_pixel(layout, base_hex)
    return center+offset


# 返回六边形所有的顶点坐标
static func get_hex_corner_pixel(layout:HexLayout, coord: Hex) -> Array:
    var result = []
    for corner in get_all_corner(coord):
        result.append(corner_to_pixel(layout, corner))
    return result