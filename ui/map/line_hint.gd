extends Control

# 道路提示


var _callback: FuncRef
var _params: Array


func _ready():
    $AnimationPlayer.play("twink")


# 设置点击回调
func set_callback(cb: FuncRef, params: Array):
    _callback = cb
    _params = params


# 设置位置
func set_pos(begin: Vector2, end: Vector2):
    rect_size.x = (begin-end).length()
    var middle = (begin+end)/2
    Util.set_center(self, middle)
    rect_pivot_offset = rect_size/2
    var distance = end - begin
    rect_rotation = rad2deg(atan2(distance.y, distance.x))


func _on_button_down():
    if _callback:
        _callback.call_funcv(_params)