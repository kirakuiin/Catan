extends Control

# 开发卡区域


const Card:PackedScene = preload("res://ui/game/zone/dev_card.tscn")


var _card_dict: Dictionary
var _card_sort: Array


func _init():
	_card_dict = {}
	_card_sort = []


# 返回碰撞区域
func get_area():
	return $Area


# 打出卡牌
func play_card(dev_type):
	_modify_pile(dev_type, _card_dict[dev_type].get_num()-1)
	_get_client().request_play_card(dev_type)


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
		_modify_pile(dev_type, num)
	
func _is_self(player_name: String):
	return player_name == PlayerInfoMgr.get_self_info().player_name

func _modify_pile(type: int, num: int):
	if num == 0:
		_del_card(type)
	else:
		_set_card(type, num)

func _set_card(dev_type: int, num: int):
	if dev_type in _card_dict:
		_card_dict[dev_type].set_num(num)
	else:
		_add_card(dev_type, num)
		_card_sort.append(dev_type)
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
		_card_sort.erase(dev_type)
		_rearrange_card()


# 重排卡牌
func _rearrange_card():
	for i in len(_card_sort):
		_place_card_by_idx(i)

func _place_card_by_idx(idx: int):
	var card = _card_dict[_card_sort[idx]]
	var type_num = len(_card_dict)
	if type_num*card.get_width() <= rect_size.x:
		card.notify_change_pos(Vector2(card.get_width()*idx, 0))
	else:
		var each_space = (rect_size.x-card.get_width())/max(1, (type_num-1))
		card.notify_change_pos(Vector2(each_space*idx, 0))
	card.z_index = idx
