extends Node2D


# 拖拽区域

class_name DragArea


signal drag_started(pos) # Vector2
signal mouse_moved(relative) # Vector2
signal drag_ended(pos) # Vector2


var _dragging : bool = false
var _area: Rect2 = Rect2(Vector2(), Vector2())
export(int, "无", "左键", "右键", "中键") var button_type = BUTTON_RIGHT  # 触发按键类型


# 设置生效区域
func set_enable_rect(rect: Rect2):
    _area = rect


func _input(event):
    if event is InputEventMouseButton:
        _handle_mouse_button(event)
    elif event is InputEventMouseMotion:
        _handle_mouse_motion(event)


func _handle_mouse_button(event: InputEventMouseButton):
    if event.button_index == button_type:
        if event.pressed:
            if not (_area.size and not _area.has_point(event.position)):
                _dragging = true
                emit_signal("drag_started", event.position)
        else:
            if _dragging:
                _dragging = false
                emit_signal("drag_ended", event.position)


func _handle_mouse_motion(event: InputEventMouseMotion):
    if _dragging:
        emit_signal("mouse_moved", event.relative)
