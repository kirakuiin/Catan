extends Node2D

# 资源卡


var _inc_cb: FuncRef
var _inc_params: Array
var _dec_cb: FuncRef
var _dec_params: Array


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


# 启动
func enable(inc_cb: FuncRef, inc_params: Array, dec_cb: FuncRef, dec_params: Array):
    _inc_cb = inc_cb
    _inc_params = inc_params
    _dec_cb = dec_cb
    _dec_params = dec_params
    $AnimationPlayer.play("twink")


# 禁止
func disable():
    _inc_params = []
    _dec_params = []
    $AnimationPlayer.play("RESET")


func _on_inc_down():
    _inc_cb.call_funcv(_inc_params)


func _on_dec_down():
    _dec_cb.call_funcv(_dec_params)