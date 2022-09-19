extends Control


# 卡坦地图ui表示


const Tile: PackedScene = preload("res://ui/map/tile.tscn")
const Property: PackedScene = preload("res://ui/map/property.tscn")

var _map: Protocol.MapInfo
var _tile_map: Dictionary = {}

var _point_map: Dictionary = {}
var _property_map: Dictionary = {}


func _ready():
	pass


func show_preview(map: Protocol.MapInfo, is_enable_fog: bool):
	_map = map
	_draw_map()
	set_all_point_visible(not is_enable_fog)


func init_with_mapinfo(map: Protocol.MapInfo, is_enable_fog: bool):
	show_preview(map, is_enable_fog)
	_generate_point()


func _draw_map():
	_clear_all()
	_draw_base()
	_draw_harbor()


# 设置所有地块点数的显隐
func set_all_point_visible(is_visible: bool):
	for child in $Tile.get_children():
		child.set_point_visible(is_visible)


func get_map_size():
	return $Backgroud.rect_size


# 在地图上增加定居点
func add_settlement_to_map(pos: Vector3, order: int):
	var settlement = Property.instance()
	settlement.set_pos(_corner_to_pos(pos))
	settlement.set_order(order)
	_property_map[pos] = settlement
	$Property.add_child(settlement)


# 在地图上增加道路
func add_road_to_map(road: Protocol.RoadInfo, order):
	$Road.draw_line(_corner_to_pos(road.begin), _corner_to_pos(road.end), Data.ORDER_DATA[order], 5, true)


# 升级地图上的城市
func upgrade_settlement_on_map(pos: Vector3):
	_property_map[pos].upgrade_to_city()


func _draw_base():
	for tile_info in _map.grid_map.values():
		var tile = Tile.instance()
		tile.set_tile_info(tile_info)
		$Tile.add_child(tile)
		_tile_map[tile_info.cube_pos] = tile


func _draw_harbor():
	for harbor_info in _map.harbor_list:
		_tile_map[harbor_info.cube_pos].set_harbor_type(harbor_info.harbor_type, harbor_info.harbor_angle)


func _clear_all():
	for child in $Tile.get_children():
		child.free()
	for child in $Property.get_children():
		child.free()
	_tile_map.clear()
	_point_map.clear()


func _generate_point():
	for tile_info in _map.grid_map.values():
		if tile_info.tile_type != Data.TileType.OCEAN:
			var hex = Hexlib.Hex.new(tile_info.cube_pos.x, tile_info.cube_pos.y, tile_info.cube_pos.z)
			_add_point(hex)


func _add_point(hex: Hexlib.Hex):
	var corners = Hexlib.get_all_corner(hex)
	for corner in corners:
		var pos = corner.to_vector3()
		if not pos in _point_map:
			_point_map[pos] = true


func _corner_to_pos(pos: Vector3) -> Vector2:
	var corner = Hexlib.Corner.new()
	corner.from_vector3(pos)
	return Hexlib.corner_to_pixel(_get_layout(), corner)


func _get_layout():
	return _tile_map.values()[0].get_layout()
