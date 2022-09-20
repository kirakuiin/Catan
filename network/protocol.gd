extends Node

# 网络协议

class_name Protocol


# 类名:类映射
static func get_cls(cls_name) -> ProtocolData:
	var map = {
		"HostInfo": HostInfo,
		"PlayerInfo": PlayerInfo,
		"CatanSetupInfo": CatanSetupInfo,
		"PlayerOrderInfo": PlayerOrderInfo,
		"TileInfo": TileInfo,
		"MapInfo": MapInfo,
		"HarborInfo": HarborInfo,
		"PlayerScoreInfo": PlayerScoreInfo,
		"PlayerBuildingInfo": PlayerBuildingInfo,
		"RoadInfo": RoadInfo,
		"AssistInfo": AssistInfo,
	}
	return map[cls_name]


class ProtocolData:
	extends Reference

	var cls_name: String = "ProtocolData"

	func _to_string() -> String:
		var string = "%s{" % cls_name
		for property in get_property_list():
			if is_export(property.name) and property.name != "cls_name":
				string += "%s=%s, " % [property.name, get(property.name)]
		string += "}"
		return string

	# 转为网络协议需要的数据
	func to_var() -> Dictionary:
		var result = {}
		for property in get_property_list():
			if is_export(property.name):
				result[property.name] = get(property.name)
		return result

	# 加载数据到类中
	func load_var(data: Dictionary):
		for name in data:
			if is_export(name):
				set(name, data[name])

	func is_export(name: String):
		return name.match("?*_?*")


# 序列化数据
static func serialize(datas):
	var result = datas
	if datas is ProtocolData:
		result = serialize(datas.to_var())
	elif datas is Array:
		result = []
		for data in datas:
			result.append(serialize(data))
	elif datas is Dictionary:
		result = {}
		for key in datas:
			result[key] = serialize(datas[key])
	return result


# 反序列化数据
static func deserialize(net_data):
	var result = net_data
	if net_data is Dictionary:
		result = {}
		for key in net_data:
			result[key] = deserialize(net_data[key])
		if "cls_name" in net_data:
			var datas = result
			result = get_cls(net_data["cls_name"]).new()
			result.load_var(datas)
	elif net_data is Array:
		result = []
		for data in net_data:
			result.append(deserialize(data))
	return result


# 主机信息
class HostInfo:
	extends ProtocolData

	var host_name: String
	var cur_player_num: int
	var max_player_num: int
	var icon_id: int
	var host_state: int

	func _init(name="", icon=1, cur_num=0, max_num=0, state=Data.HostState.PREPARE):
		cls_name = "HostInfo"
		host_name = name
		cur_player_num = cur_num
		max_player_num = max_num
		host_state = state
		icon_id = icon


# 玩家信息
class PlayerInfo:
	extends ProtocolData

	var player_name: String
	var peer_id: int
	var icon_id: int

	func _init(name="", id=0, icon=0):
		cls_name = "PlayerInfo"
		player_name = name
		peer_id = id
		icon_id = icon


# 创建玩家数据
static func create_player_info_by_id(peer_id: int) -> PlayerInfo:
	return PlayerInfo.new(PlayerConfig.get_player_name(), peer_id, PlayerConfig.get_icon_id())


# 卡坦岛设置信息
class CatanSetupInfo:
	extends ProtocolData

	var catan_size: int
	var is_enable_fog: bool
	var is_random_land: bool
	var is_random_order: bool
	var is_random_resource: bool

	func _init(size=Data.CatanSize.SMALL, fog=false, land=false, order=false, resource=false):
		cls_name = "CatanSetupInfo"
		catan_size = size
		is_enable_fog = fog
		is_random_land = land
		is_random_order = order
		is_random_resource = resource


# 玩家顺序信息
class PlayerOrderInfo:
	extends ProtocolData

	var order_to_name: Dictionary

	func _init():
		cls_name = "PlayerOrderInfo"
		order_to_name = {}

	func get_order(name: String) -> int:
		for order in order_to_name:
			if order_to_name[order] == name:
				return order
		return -1

	func get_name(order: int) -> String:
		return order_to_name.get(order, "")


# 地块信息
class TileInfo:
	extends ProtocolData

	var cube_pos: Vector3
	var tile_type: int
	var point_type: int

	func _init(pos: Vector3=Vector3(0, 0, 0), tile=Data.TileType.DESERT, point=Data.PointType.ZERO):
		cls_name = "TileInfo"
		cube_pos = pos
		tile_type = tile
		point_type = point

	func to_hex() -> Hexlib.Hex:
		return Hexlib.create_hex(cube_pos)


# 港口信息
class HarborInfo:
	extends ProtocolData

	var cube_pos: Vector3
	var harbor_type: int
	var harbor_angle: float

	func _init(pos: Vector3=Vector3(0, 0, 0), type=Data.HarborType.GENERIC, angle=0.0):
		cls_name = "HarborInfo"
		cube_pos = pos
		harbor_type = type
		harbor_angle = angle


# 地图信息
class MapInfo:
	extends ProtocolData

	var grid_map: Dictionary
	var harbor_list: Array

	func _init(map: Dictionary={}, harbor: Array=[]):
		cls_name = "MapInfo"
		grid_map = map
		harbor_list = harbor


	func add_tile(tile: TileInfo):
		grid_map[tile.cube_pos] = tile


	func add_harbor(pos: Vector3, harbor_type: int):
		harbor_list.append(harbor_type)


# 玩家分数信息
class PlayerScoreInfo:
	extends ProtocolData

	var res_cards: Dictionary
	var dev_cards: Dictionary
	var vic_point: int
	var army_num: int
	var continue_road: int

	func _init(res: Dictionary={}, dev: Dictionary={}, vp: int=0, army :int=0, cont :int=0):
		cls_name = "PlayerScoreInfo"
		res_cards = res
		dev_cards = dev
		vic_point = vp
		army_num = army
		continue_road = cont
		
	
# 玩家资源卡信息


# 玩家建筑信息
class PlayerBuildingInfo:
	extends ProtocolData

	var city_info: Array
	var settlement_info: Array
	var road_info: Array

	func _init(citys: Array=[], settlements: Array=[], roads: Array=[]):
		cls_name = "PlayerBuildingInfo"
		city_info = citys
		settlement_info = settlements
		road_info = roads


# 道路信息
class RoadInfo:
	extends ProtocolData
	
	var begin_node: Vector3
	var end_node: Vector3

	func _init(b: Vector3=Vector3(0, 0, 0), e: Vector3=Vector3(0, 0, 0)):
		cls_name = "RoadInfo"
		begin_node = b
		end_node = e

	func to_tuple():
		var tuple = [begin_node, end_node]
		tuple.sort()
		return tuple


# 从元组中创建到道路
static func create_road(tuple: Array):
	return RoadInfo.new(tuple[0], tuple[1])


# 辅助信息
class AssistInfo:
	extends ProtocolData

	var turn_num: int
	var player_turn_name: String
	var longgest_name: String
	var biggest_name: String

	func _init(turn: int=0, turn_name: String=""):
		cls_name = "AssistInfo"
		turn_num = turn
		player_turn_name = turn_name
		longgest_name = ""
		biggest_name = ""