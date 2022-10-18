extends Node

# 网络协议

class_name Protocol


# 类名:类映射
static func get_cls(cls_name) -> ProtocolData:
    var map = {
        "HostInfo": HostInfo,
        "ServerResponseInfo": ServerResponseInfo,
        "PlayerInfo": PlayerInfo,
        "CatanSetupInfo": CatanSetupInfo,
        "SettlerModeInfo": SettlerModeInfo,
        "SeafarerModeInfo": SeafarerModeInfo,
        "PlayerOrderInfo": PlayerOrderInfo,
        "TileInfo": TileInfo,
        "MapInfo": MapInfo,
        "HarborInfo": HarborInfo,
        "PlayerCardInfo": PlayerCardInfo,
        "PlayerBuildingInfo": PlayerBuildingInfo,
        "RoadInfo": RoadInfo,
        "PlayerPersonalInfo": PlayerPersonalInfo,
        "AssistInfo": AssistInfo,
        "BankInfo": BankInfo,
        "TradeInfo": TradeInfo,
        "StatInfo": StatInfo,
        "NotificationInfo": NotificationInfo,
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
                var val = get(property.name)
                if val is Dictionary or val is Array:
                    val = val.duplicate(true)
                result[property.name] = val
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
    var result = _serialize(datas)
    return var2str(result)

static func _serialize(datas):
    var result = datas
    if datas is ProtocolData:
        result = _serialize(datas.to_var())
    elif datas is Array:
        result = []
        for data in datas:
            result.append(_serialize(data))
    elif datas is Dictionary:
        result = {}
        for key in datas:
            result[key] = _serialize(datas[key])
    return result


# 反序列化数据
static func deserialize(net_data) -> ProtocolData:
    net_data = str2var(net_data)
    return _deserialize(net_data)

static func _deserialize(net_data) -> ProtocolData:
    var result = net_data
    if net_data is Dictionary:
        result = {}
        for key in net_data:
            result[key] = _deserialize(net_data[key])
        if "cls_name" in net_data:
            var datas = result
            result = get_cls(net_data["cls_name"]).new()
            datas.erase("cls_name")
            result.load_var(_deserialize(datas))
    elif net_data is Array:
        result = []
        for data in net_data:
            result.append(_deserialize(data))
    return result


# 复制数据
static func copy(val: ProtocolData) -> ProtocolData:
    return deserialize(serialize(val))


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


# 服务器回复信息
class ServerResponseInfo:
    extends ProtocolData

    var is_success: bool
    var res_reason: String

    func _init(success: bool=true, reason: String=""):
        cls_name = "ServerResponseInfo"
        is_success = success
        res_reason = reason


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
    return PlayerInfo.new(GameConfig.get_player_name(), peer_id, GameConfig.get_icon_id())


# 卡坦岛设置信息
class CatanSetupInfo:
    extends ProtocolData

    var catan_size: int
    var is_enable_fog: bool
    var is_random_order: bool
    var is_random_resource: bool
    var expansion_mode: ProtocolData

    var initial_res: int
    var win_vp: int
    var custom_dev: bool

    func _init(size=Data.CatanSize.SMALL, fog=false, order=false, resource=false):
        cls_name = "CatanSetupInfo"
        catan_size = size
        is_enable_fog = fog
        is_random_order = order
        is_random_resource = resource
        expansion_mode = SettlerModeInfo.new()

        initial_res = 0
        win_vp = 10
        custom_dev = false

    func is_settler() -> bool:
        return expansion_mode.mode_type == Data.ExpansionMode.SETTLER

    func is_seafarer() -> bool:
        return expansion_mode.mode_type == Data.ExpansionMode.SEAFARER

    func change_mode_by_idx(idx: int):
        if idx == Data.ExpansionMode.SETTLER:
            expansion_mode = SettlerModeInfo.new()
        elif idx == Data.ExpansionMode.SEAFARER:
            expansion_mode = SeafarerModeInfo.new()

    func mode_idx() -> int:
        return expansion_mode.mode_type


# 标准版设置信息
class SettlerModeInfo:
    extends ProtocolData

    const mode_type: int = Data.ExpansionMode.SETTLER
    var is_random_land: bool
    var selected_map: String

    func _init(rand_land: bool=false, selected: String=""):
        cls_name = "SettlerModeInfo"
        is_random_land = rand_land
        selected_map = selected


# 航海家版设置信息
class SeafarerModeInfo:
    extends ProtocolData

    const mode_type: int = Data.ExpansionMode.SEAFARER
    var selected_map: int

    func _init(select: int=0):
        cls_name = "SeafarerModeInfo"
        selected_map = select


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

    func _init(pos: Vector3=Vector3(0, 0, 0), tile=Data.TileType.NULL, point=Data.PointType.ZERO):
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
    var near_pos: Vector3
    var harbor_type: int

    func _init(pos: Vector3=Vector3(0, 0, 0), near: Vector3=Vector3(0, 0, 0), type=Data.HarborType.NULL):
        cls_name = "HarborInfo"
        cube_pos = pos
        near_pos = near
        harbor_type = type

    func get_harbor_angle() -> float:
        return Hexlib.hex_relative_angle(Hexlib.create_hex(cube_pos), Hexlib.create_hex(near_pos))

    func get_harbor_corner() -> Array:
        var result = []
        for corner in Hexlib.hex_intersect(Hexlib.create_hex(cube_pos), Hexlib.create_hex(near_pos)):
            result.append(corner.to_vector3())
        return result


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

    func get_all_harbor_near_corner() -> Array:
        var result = []
        for harbor in harbor_list:
            result.append_array(harbor.get_harbor_corner())
        return result


# 玩家卡牌信息
class PlayerCardInfo:
    extends ProtocolData

    var res_cards: Dictionary
    var dev_cards: Dictionary

    func _init(res: Dictionary={}, dev: Dictionary={}):
        cls_name = "PlayerCardInfo"
        res_cards = res
        dev_cards = dev

    func is_have_card() -> bool:
        return StdLib.sum(res_cards.values()) + StdLib.sum(dev_cards.values()) > 0


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

    func get_settlement_and_city() -> StdLib.Set:
        return StdLib.Set.new(city_info + settlement_info)

    func get_all_road_point() -> StdLib.Set:
        var result = StdLib.Set.new()
        for road in road_info:
            result.add(road.begin_node)
            result.add(road.end_node)
        return result


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


# 玩家个人信息
class PlayerPersonalInfo:
    extends ProtocolData
    
    var is_played_card: bool
    var vic_point: int
    var army_num: int
    var continue_road: int

    func _init(is_played=false, vp: int=0, army :int=0, cont :int=0):
        cls_name = "PlayerPersonalInfo"
        is_played_card = is_played
        vic_point = vp
        army_num = army
        continue_road = cont


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


# 银行信息
class BankInfo:
    extends ProtocolData

    var avail_card: int
    var res_info: Dictionary

    func _init(catan_size: int=Data.CatanSize.SMALL):
        cls_name = "BankInfo"
        res_info = Data.SETTLER_DATA[catan_size].resource.each_num.duplicate(true)
        avail_card = Data.SETTLER_DATA[catan_size].card.total_num


# 交易信息
class TradeInfo:
    extends ProtocolData

    const BANK = "[_$Bank$_]"

    var from_player: String
    var to_player: String
    var get_info: Dictionary
    var pay_info: Dictionary
    var trade_state: String

    func _init(from: String="", to: String=BANK, get: Dictionary={}, pay: Dictionary={}):
        cls_name = "TradeInfo"
        from_player = from
        to_player = to
        get_info = get
        pay_info = pay
        trade_state = NetDefines.TradeState.NEGOTIATE
        
    func init_by_dict(trade_info: Dictionary):
        for res_type in trade_info:
            var num = trade_info[res_type]
            if num > 0:
                get_info[res_type] = num
            elif num < 0:
                pay_info[res_type] = abs(num)

    func flip():
        var tmp = from_player
        from_player = to_player
        to_player = tmp
        tmp = get_info
        get_info = pay_info
        pay_info = tmp


# 统计数据
class StatInfo:
    extends ProtocolData
    
    var total_time: int
    var winner_name: String
    var dice_info: Dictionary
    var turn_num: int

    func _init(time=0, winner: String="", dice: Dictionary={}):
        cls_name = "StatInfo"
        total_time = time
        winner_name = winner
        dice_info = dice
        turn_num = 0


# 通告
class NotificationInfo:
    extends ProtocolData

    var notify_type: int
    var notify_params: Dictionary

    func _init(type: int=NetDefines.NotificationType.NONE, params: Dictionary={}):
        cls_name = "NotificationInfo"
        notify_type = type
        notify_params = params


