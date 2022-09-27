extends Reference

# 卡牌管理器

var _scores: Dictionary
var _size: int
var _bank: Protocol.BankInfo

var _card_capacity: Dictionary


func _init(scores: Dictionary, size: int, bank: Protocol.BankInfo):
    _scores = scores
    _size = size
    _bank = bank
    _card_capacity = Data.NUM_DATA[size].card.each_num.duplicate(true)


# 打出卡牌
func play_card(player_name: String, dev_type: int):
    _scores[player_name].dev_cards[dev_type] -= 1


# 给予玩家一张随机卡牌
func give_card_to_player(player_name: String) -> int:
    var rand_type = []
    for type in _card_capacity:
        for _i in  _card_capacity[type]:
            rand_type.append(type)
    rand_type.shuffle()
    var type = rand_type[0]
    _modify_capacity(type)
    Util.merge_int_dict(_scores[player_name].dev_cards, {type: 1})
    return type
    
func _modify_capacity(type: int):
    _card_capacity[type] -= 1
    _bank.avail_card -= 1
    Log.logd("类型[%d]的卡牌由(%d->%d)" % [type, _card_capacity[type]+1, _card_capacity[type]])
            