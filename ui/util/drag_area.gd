extends Node2D


# 拖拽区域

class_name DragArea


signal mouse_moved(relative)


var _dragging : bool = false
export(int, "无", "左键", "右键", "中键") var button_type = BUTTON_RIGHT  # 触发按键类型


func _input(event):
    if event is InputEventMouseButton:
        _handle_mouse_button(event)
    elif event is InputEventMouseMotion:
        _handle_mouse_motion(event)


func _handle_mouse_button(event: InputEventMouseButton):
    if event.button_index == button_type:
        if event.pressed:
            _dragging = true
        else:
            _dragging = false


func _handle_mouse_motion(event: InputEventMouseMotion):
    if _dragging:
        emit_signal("mouse_moved", event.relative)
