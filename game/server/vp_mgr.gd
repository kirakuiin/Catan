extends Reference

# 胜点管理器


var _cards: Dictionary
var _buildings: Dictionary
var _assist: Protocol.AssistInfo


func _init(cards: Dictionary, buildings: Dictionary, assist_info: Protocol.AssistInfo):
    _cards = cards
    _buildings = buildings
    _assist = assist_info


# 更新玩家信息
func update_player_info(player_name: String):
    _cards[player_name].vic_point = _calc_vp(player_name)


func _calc_vp(player_name: String):
    var vp := 0
    var building = _buildings[player_name]
    vp += len(building.settlement_info)
    vp += len(building.city_info)*2
    vp += StdLib.dict_get(_cards[player_name].dev_cards, Data.CardType.VP, 0)
    if _assist.longgest_name == player_name:
        vp += 2
    if _assist.biggest_name == player_name:
        vp += 2
    return vp
