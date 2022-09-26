extends Control


# 开发卡区域

func _ready():
    $Area/Collision.shape.extents = rect_size/2
    $Area/Collision.position = rect_size/2