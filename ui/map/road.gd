extends Control

# 道路


func _ready():
	pass


# 设置位置
func set_pos(begin: Vector2, end: Vector2):
    rect_size.x = (begin-end).length()
    var middle = (begin+end)/2
    Util.set_center(self, middle)
    rect_pivot_offset = rect_size/2
    var distance = end - begin
    rect_rotation = rad2deg(atan2(distance.y, distance.x))


func set_order(order: int):
	var color = UI_Data.ORDER_DATA[order]
	$Road.modulate = color