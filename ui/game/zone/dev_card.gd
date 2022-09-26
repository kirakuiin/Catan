extends Node2D


# 开发卡

const UP := Vector2(0, -180)
const SCALE := Vector2(1.6, 1.6)

var _type: int



# 设置卡牌类型
func set_type(dev_type: int):
    _type = dev_type
    $CardImage.texture = ResourceLoader.load(Data.CARD_DATA[dev_type])


# 获得类型
func get_type() -> int:
    return _type


# 设置高度
func set_height(height: float):
    var ratio = $CardImage.rect_min_size.x/$CardImage.rect_min_size.y
    $CardImage.rect_size.y = height
    $CardImage.rect_size.x = ratio*height
    _update_collision()

func _update_collision():
    $CardImage/Area.position = $CardImage.rect_size/2
    $CardImage/Area/Collision.shape.extents = $CardImage.rect_size/2


# 获得宽度
func get_width() -> float:
    return $CardImage.rect_size.x


# 设置数量
func set_num(num: int):
    $CardImage/Num.text = "x%d" % num


# 得到数量
func get_num() -> int:
    return int($CardImage/Num.text.right(1))


func _on_mouse_entered():
    position += UP
    position.x -= $CardImage.rect_size.x*(SCALE.x-1)/2
    scale *= SCALE


func _on_mouse_exited():
    scale /= SCALE
    position.x += $CardImage.rect_size.x*(SCALE.x-1)/2
    position -= UP