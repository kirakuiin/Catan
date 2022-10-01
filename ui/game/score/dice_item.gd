extends Control


# 骰子点数数据


# 设置数据
func set_data(point: int, num: int):
    $Root/Point.text = "%d点" % point
    $Root/Num.text = "%d次" % num
    if point in [2, 12]:
        $Root.modulate = Color.aqua
    elif point in [6, 8]:
        $Root.modulate = Color.orangered
    elif point == 7:
        $Root.modulate = Color.gold

