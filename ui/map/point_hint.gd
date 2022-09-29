extends Control

# 点提示


var _callback: FuncRef
var _params: Array


func _ready():
    $Circle.rect_pivot_offset = $Circle.rect_size/2
    hide()


func set_callback(cb: FuncRef, param: Array):
    _callback = cb
    _params = param


func set_hint_color(color: Color):
    modulate = color


func set_pos(pos: Vector2):
    Util.set_center(self, pos)


func _on_button_down():
    if _callback:
        _callback.call_funcv(_params)


func show():
    .show()
    $AnimationPlayer.play("pulsation")


func hide():
    .hide()
    $AnimationPlayer.stop(true)