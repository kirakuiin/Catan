extends Node2D

# 资源卡


var _cb: FuncRef
var _params: Array


# 设置卡牌类型
func set_type(res_type: int):
    $CardImage.texture = ResourceLoader.load(Data.RES_DATA[res_type])


# 设置高度
func set_height(height: float):
    var ratio = $CardImage.rect_min_size.x/$CardImage.rect_min_size.y
    $CardImage.rect_size.y = height
    $CardImage.rect_size.x = ratio*height


# 获得宽度
func get_width() -> float:
    return $CardImage.rect_size.x


# 设置数量
func set_num(num: int):
    $CardImage/Num.text = "x%d" % num


# 获得数量
func get_num() -> int:
    return int($CardImage/Num.text.right(1))


# 设置点击回调
func set_callback(cb: FuncRef, params: Array):
    _cb = cb
    _params = params


func _on_click_card():
    if _cb:
        _cb.call_funcv(_params)