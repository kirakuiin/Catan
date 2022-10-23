extends Reference

# 操作管理器


var _buildings: Dictionary
var _cards: Dictionary
var _map: Protocol.MapInfo


func _init(buildings: Dictionary, cards: Dictionary, map: Protocol.MapInfo):
    _buildings = buildings
    _cards = cards
    _map = map


# 是否可以进行建筑
func can_building() -> bool:
    return can_buy_dev() or can_place_road() or can_upgrade_city() or can_place_settlement()


# 是否可以购买发展卡
func can_buy_dev() -> bool:
    return _is_greater_than_required(_cards[_get_name()].res_cards, _get_required(Data.OpType.DEV_CARD))


# 是否升级道路
func can_upgrade_city() -> bool:
    if len(_buildings[_get_name()].city_info) == _get_building_limit(Data.OpType.CITY):
        return false
    return _is_greater_than_required(_cards[_get_name()].res_cards, _get_required(Data.OpType.CITY))


# 是否可以放置道路
func can_place_road() -> bool:
    if len(_buildings[_get_name()].road_info) == _get_building_limit(Data.OpType.ROAD):
        return false
    return _is_greater_than_required(_cards[_get_name()].res_cards, _get_required(Data.OpType.ROAD))


# 是否可以放置定居点
func can_place_settlement() -> bool:
    if len(_buildings[_get_name()].settlement_info) == _get_building_limit(Data.OpType.SETTLEMENT):
        return false
    return _is_greater_than_required(_cards[_get_name()].res_cards, _get_required(Data.OpType.SETTLEMENT))

func _get_building_limit(type: int) -> int:
    return _map.building_data[type]

func _get_required(type: int) -> Dictionary:
    return Data.OP_DATA[type]

func _is_greater_than_required(current: Dictionary, required: Dictionary):
    for res_type in required:
        if not res_type in current or current[res_type] < required[res_type]:
            return false
    return true

func _get_name():
    return PlayerInfoMgr.get_self_info().player_name