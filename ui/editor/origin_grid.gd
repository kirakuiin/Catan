extends Node2D


var layout: Hexlib.HexLayout = null


func _ready():
	position = get_parent().rect_size/2


func _draw():
	if layout:
		for hex in Hexlib.get_spiral_ring(Hexlib.create_hex(Vector3(0, 0, 0)), 15):
			var pos_list = Hexlib.get_hex_corner_pixel(layout, hex)
			draw_polyline(pos_list+[pos_list[0]], Color.aqua)
