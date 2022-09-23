extends Node2D

# 资源卡


var _inc_cb: FuncRef
var _dec_cb: FuncRef
var _type: int


# 设置卡牌类型
func set_type(res_type: int):
    _type = res_type
    $CardImage.texture = ResourceLoader.load(Data.RES_DATA[res_type])


# 获得类型
func get_type() -> int:
    return _type


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


# 设置弃牌数量
func set_discard(num: int):
    $CardImage/Discard.text = "-%d" % num


# 获得数量
func get_num() -> int:
    return int($CardImage/Num.text.right(1))


# 启动
func enable(inc_cb: FuncRef, dec_cb: FuncRef):
    _inc_cb = inc_cb
    _dec_cb = dec_cb
    $AnimationPlayer.play("twink")


# 禁止
func disable():
    $CardImage/Discard.text = "0"
    $AnimationPlayer.play("RESET")


func _on_inc_down():
    _inc_cb.call_func(self)


func _on_dec_down():
    _dec_cb.call_func(self)