extends Reference

# 卡牌管理器

var _cards: Dictionary
var _map: Protocol.MapInfo
var _bank: Protocol.BankInfo
var _personals

var _card_capacity: Dictionary


func _init(cards: Dictionary, personals: Dictionary, map: Protocol.MapInfo, bank: Protocol.BankInfo):
    _cards = cards
    _personals = personals
    _bank = bank
    _map = map
    _card_capacity = map.card_data.duplicate(true)


# 打出卡牌
func play_card(player_name: String, dev_type: int):
    _cards[player_name].dev_cards[dev_type] -= 1
    if dev_type == Data.CardType.KNIGHT:
        _personals[player_name].army_num += 1


# 给予玩家一张随机卡牌
func give_card_to_player(player_name: String) -> int:
    var rand_type = []
    for type in _card_capacity:
        for _i in  _card_capacity[type]:
            rand_type.append(type)
    rand_type.shuffle()
    var type = rand_type[0]
    _modify_capacity(type)
    StdLib.num_dict_merge(_cards[player_name].dev_cards, {type: 1})
    return type
    
func _modify_capacity(type: int):
    _card_capacity[type] -= 1
    _bank.avail_card -= 1
    Log.logd("类型[%d]的卡牌由(%d->%d)" % [type, _card_capacity[type]+1, _card_capacity[type]])
            