extends Reference

# 卡牌管理器

var _scores: Dictionary
var _size: int

var _card_capacity: Dictionary


func _init(scores: Dictionary, size: int):
    _scores = scores
    _size = size
    _card_capacity = Data.NUM_DATA[size].card.each_num.duplicate(true)


# 获得可抽卡牌总数
func get_avail_card_num() -> int:
    return Util.sum(_card_capacity.values())


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
    Log.logd("类型[%d]的卡牌由(%d->%d)" % [type, _card_capacity[type]+1, _card_capacity[type]])
            