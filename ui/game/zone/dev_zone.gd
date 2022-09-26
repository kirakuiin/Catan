extends Control

# 开发卡区域


const Card:PackedScene = preload("res://ui/game/zone/dev_card.tscn")


var _card_dict: Dictionary


func _init():
	_card_dict = {}


func init():
	_init_signal()
	_init_collision()


func _init_collision():
	$Area.position = rect_size/2
	$Area/Collision.shape.extents = rect_size/2


func _init_signal():
	_get_client().connect("score_info_changed", self, "_on_score_info_changed")


func _get_client():
	return PlayingNet.get_client()


func _on_score_info_changed(player_name: String, score_info: Protocol.PlayerScoreInfo):
	if not _is_self(player_name):
		return
	for dev_type in score_info.dev_cards:
		var num = score_info.dev_cards[dev_type]
		if num == 0:
			_del_card(dev_type)
		else:
			_set_card(dev_type, num)
	
func _is_self(player_name: String):
	return player_name == PlayerInfoMgr.get_self_info().player_name

func _set_card(dev_type: int, num: int):
	if dev_type in _card_dict:
		_card_dict[dev_type].set_num(num)
	else:
		_add_card(dev_type, num)
	_rearrange_card()

func _add_card(dev_type: int, num: int):
	var card = Card.instance()
	_card_dict[dev_type] = card
	add_child(card)
	card.set_type(dev_type)
	card.set_num(num)
	card.set_height(rect_size.y)

func _del_card(dev_type: int):
	if dev_type in _card_dict:
		_card_dict[dev_type].queue_free()
		_card_dict.erase(dev_type)
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
	return card_a.get_type() < card_b.get_type()

func _place_card_by_idx(card, idx: int):
	var type_num = len(_card_dict)
	if type_num*card.get_width() <= rect_size.x:
		card.position = Vector2(card.get_width()*idx, 0)
	else:
		var each_space = (rect_size.x-card.get_width())/max(1, (type_num-1))
		card.position = Vector2(each_space*idx, 0)
	card.z_index = idx
