extends Control


# 卡坦地图ui表示


const Tile: PackedScene = preload("res://ui/map/tile.tscn")
const Property: PackedScene = preload("res://ui/map/property.tscn")
const Road: PackedScene = preload("res://ui/map/road.tscn")
const PointHint: PackedScene = preload("res://ui/map/point_hint.tscn")
const LineHint: PackedScene = preload("res://ui/map/line_hint.tscn")
const Robber: PackedScene = preload("res://ui/map/robber.tscn")


var _map: Protocol.MapInfo
var _tile_map: Dictionary = {}

var _point_map: Dictionary = {}
var _road_map: Dictionary = {}
var _settlement_map: Dictionary = {}
var _city_map: Dictionary = {}


func _ready():
	pass


# 设置所有地块点数的显隐
func set_all_point_visible(is_visible: bool):
	for child in $Tile.get_children():
		child.set_point_visible(is_visible)


# 获得地图尺寸
func get_map_size():
	return $Backgroud.rect_size


func init_with_mapinfo(map: Protocol.MapInfo, is_enable_fog: bool):
	show_preview(map, is_enable_fog)
	_generate_point()
	_init_signal()


func show_preview(map: Protocol.MapInfo, is_enable_fog: bool):
	_map = map
	_draw_map()
	set_all_point_visible(not is_enable_fog)

func _draw_map():
	_clear_all_tile()
	_draw_base()
	_draw_harbor()


func _clear_all_tile():
	for child in $Tile.get_children():
		child.free()
	_tile_map.clear()


func _draw_base():
	for tile_info in _map.grid_map.values():
		var tile = Tile.instance()
		tile.set_tile_info(tile_info)
		$Tile.add_child(tile)
		_tile_map[tile_info.cube_pos] = tile


func _draw_harbor():
	for harbor_info in _map.harbor_list:
		_tile_map[harbor_info.cube_pos].set_harbor_type(harbor_info.harbor_type, harbor_info.harbor_angle)


func _generate_point():
	for point in _get_client().point_info.values():
		_create_point(point)

	
func _get_client():
	return PlayingNet.get_client()


func _create_point(pos: Vector3):
	var hint = PointHint.instance()
	_point_map[pos] = hint
	$Point.add_child(hint)
	hint.set_pos(_corner_to_pos(pos))


func _corner_to_pos(pos: Vector3) -> Vector2:
	var corner = Hexlib.create_corner(pos)
	return Hexlib.corner_to_pixel(_get_layout(), corner)


func _get_layout():
	return _tile_map.values()[0].get_layout()


func _init_signal():
	_get_client().connect("building_info_changed", self, "_on_building_info_changed")
	_get_client().connect("client_state_changed", self, "_on_client_state_changed")
	_get_client().connect("robber_pos_changed", self, "_on_robber_pos_changed")


func _on_building_info_changed(player_name: String, building_info: Protocol.PlayerBuildingInfo):
	var order = _get_client().order_info.get_order(player_name)
	for settlement in building_info.settlement_info:
		if not settlement in _settlement_map:
			_add_settlement_to_map(settlement, order)
	for city in building_info.city_info:
		if not city in _city_map:
			_upgrade_settlement_on_map(city)
	for road in building_info.road_info:
		if not road.to_tuple() in _road_map:
			_add_road_to_map(road, order)


func _on_client_state_changed(state):
	match state:
		NetDefines.ClientState.PLACE_ROAD_SETUP:
			_show_road_hint(true)
		NetDefines.ClientState.PLACE_ROAD_TURN:
			_show_road_hint(false)
		NetDefines.ClientState.PLACE_SETTLEMENT:
			_show_settlement_hint()
		NetDefines.ClientState.UPGRADE_CITY:
			_show_upgrade_hint()


# 展示定居点提示
func _show_settlement_hint():
	for point in _get_client().get_available_point():
		_point_map[point].show()
		_point_map[point].set_callback(funcref(self, "_on_click_point"), [point])

func _on_click_point(point):
	for point in _point_map.values():
		point.hide()
	_get_client().place_settlement_done(point)


# 展示道路提示
func _show_road_hint(is_setup=false):
	var roads = _get_client().get_setup_available_road() if is_setup else _get_client().get_turn_available_road()
	for road in roads:
		_create_road_hint(road)
		
func _create_road_hint(road: Protocol.RoadInfo):
	var hint = LineHint.instance()
	$Line.add_child(hint)
	hint.set_pos(_corner_to_pos(road.begin_node), _corner_to_pos(road.end_node))
	hint.set_callback(funcref(self, "_on_click_line"), [road])

func _on_click_line(road: Protocol.RoadInfo):
	for child in $Line.get_children():
		child.queue_free()
	_get_client().place_road_done(road)


# 展示升级提示
func _show_upgrade_hint():
	pass


# 在地图上增加定居点
func _add_settlement_to_map(pos: Vector3, order: int):
	var settlement = Property.instance()
	$Property.add_child(settlement)
	settlement.set_pos(_corner_to_pos(pos))
	settlement.set_order(order)
	_settlement_map[pos] = settlement


# 在地图上增加道路
func _add_road_to_map(road_info: Protocol.RoadInfo, order: int):
	var road = Road.instance()
	$Road.add_child(road)
	road.set_pos(_corner_to_pos(road_info.begin_node), _corner_to_pos(road_info.end_node))
	road.set_order(order)
	_road_map[road_info.to_tuple()] = road


# 升级地图上的城市
func _upgrade_settlement_on_map(pos: Vector3):
	_city_map[pos] = _settlement_map.erase(pos)
	_city_map[pos].upgrade_to_city()


func _on_robber_pos_changed(pos: Vector3):
	$Robber/Robber.show()
	var hex = Hexlib.create_hex(pos)
	$Robber/Robber.position = Hexlib.hex_to_pixel(_get_layout(), hex)