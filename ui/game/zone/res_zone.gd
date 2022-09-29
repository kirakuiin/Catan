extends Control


# 卡牌区域


const Card:PackedScene = preload("res://ui/game/zone/res_card.tscn")


var _card_dict: Dictionary
var _need_discard_num: int
var _discard_info: Dictionary


func _init():
    _card_dict = {}


func init():
    _init_signal()


func _init_signal():
    _get_client().connect("card_info_changed", self, "_on_card_info_changed")
    _get_client().connect("resource_discarded", self, "_on_resource_discarded")


func _get_client():
    return PlayingNet.get_client()


func _on_card_info_changed(player_name: String, card_info: Protocol.PlayerCardInfo):
    if not _is_self(player_name):
        return
    for res_type in card_info.res_cards:
        var num = card_info.res_cards[res_type]
        if num == 0:
            _del_card(res_type)
        else:
            _set_card(res_type, num)
    
func _is_self(player_name: String):
    return player_name == PlayerInfoMgr.get_self_info().player_name

func _set_card(res_type: int, num: int):
    if res_type in _card_dict:
        _card_dict[res_type].set_num(num)
    else:
        _add_card(res_type, num)
    _rearrange_card()

func _add_card(res_type: int, num: int):
    var card = Card.instance()
    _card_dict[res_type] = card
    add_child(card)
    card.set_type(res_type)
    card.set_num(num)
    card.set_height(rect_size.y)

func _del_card(res_type: int):
    if res_type in _card_dict:
        _card_dict[res_type].queue_free()
        _card_dict.erase(res_type)
        _rearrange_card()


# 重排卡牌
func _rearrange_card():
    var sort_cards = _get_sort_cards()
    for i in len(sort_cards):
        _place_card_by_idx(sort_cards[i], i)

func _get_sort_cards() -> Array:
   var list = _card_dict.values()
   list.sort_custom(self, "_sort_descending")
   return list

func _sort_descending(card_a, card_b) -> bool:
    return card_a.get_num() > card_b.get_num()

func _place_card_by_idx(card, idx: int):
    var type_num = len(_card_dict)
    if type_num*card.get_width() <= rect_size.x:
        card.position = Vector2(card.get_width()*idx, 0)
    else:
        var each_space = (rect_size.x-card.get_width())/max(1, (type_num-1))
        card.position = Vector2(each_space*idx, 0)
    card.z_index = idx
    

func _on_resource_discarded(num: int):
    _init_discard(num)
    for card in _card_dict.values():
        card.enable(funcref(self, "_on_inc"), funcref(self, "_on_dec"))

func _init_discard(num: int):
    _need_discard_num = num
    _discard_info = {}
    for res_type in _card_dict:
        _discard_info[res_type] = 0
    $Discard.show()
    $Discard/DiscardBtn.hide()
    _update_discard_hint()


func _on_inc(button):
    var res_type = button.get_type()
    if _discard_info[res_type] > 0:
        _discard_info[res_type] -= 1
        button.set_num(button.get_num()+1)
        button.set_discard(_discard_info[res_type])
        _update_discard_hint()


func _on_dec(button):
    var res_type = button.get_type()
    if button.get_num() > 0 and _calc_discard_diff() > 0:
        _discard_info[res_type] += 1
        button.set_num(button.get_num()-1)
        button.set_discard(_discard_info[res_type])
        _update_discard_hint()


func _calc_discard_diff():
    var total = StdLib.sum(_discard_info.values())
    return _need_discard_num - total


func _update_discard_hint():
    var diff = _calc_discard_diff()
    if diff > 0:
        $Discard/Hint.text = "仍需丢弃[%d]张资源卡" % diff
        $Discard/DiscardBtn.hide()
    else:
        $Discard/Hint.text = ""
        $Discard/DiscardBtn.show()


func _on_confirm_discard():
    _disable_discard()
    _get_client().discard_done(_discard_info)

func _disable_discard():
    for card in _card_dict.values():
        card.disable()
    $Discard.hide()
