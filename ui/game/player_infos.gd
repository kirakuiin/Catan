extends Control


# 玩家列表


const PlayerInfo: PackedScene = preload("res://ui/player/player_info.tscn")

const HIGH_LIGHT: Color = Color.turquoise
const NORMAL: Color = Color(0, 0, 0, 0)

var _cur_sort_func: String = "_sort_by_order"


func init():
    _init_player_list()
    _init_signal()

func _init_player_list():
    var order_info = _get_client().order_info
    var orders = order_info.order_to_name.keys()
    orders.sort()
    for order in orders:
        var item = PlayerInfo.instance()
        item.init(order, order_info.order_to_name[order], _get_client().setup_info)
        $VCon/PlayerList.add_child(item)

func _init_signal():
    _get_client().connect("personal_info_changed", self, "_on_personal_info_changed")
    _get_client().connect("building_info_changed", self, "_on_building_info_changed")
    _get_client().connect("card_info_changed", self, "_on_card_info_changed")

func _on_personal_info_changed(player_name, info):
    if _cur_sort_func in ["_sort_by_vp"]:
        _resort_list()

func _on_building_info_changed(player_name, info):
    if _cur_sort_func in ["_sort_by_settlement", "_sort_by_city"]:
        _resort_list()

func _on_card_info_changed(player_name, info):
    if _cur_sort_func in ["_sort_by_dev", "_sort_by_res"]:
        _resort_list()


func _get_client():
    return PlayingNet.get_client()


func _set_color(obj: ColorRect, is_pressed: bool):
    if is_pressed:
        obj.color = HIGH_LIGHT
    else:
        obj.color = NORMAL


func _on_order_toggled(button_pressed: bool):
    _set_color($VCon/Option/Order, button_pressed)
    _cur_sort_func = "_sort_by_order"
    _resort_list()

func _sort_by_order(a, b):
    return a.get_order_num() < b.get_order_num()


func _on_res_toggled(button_pressed: bool):
    _set_color($VCon/Option/Res, button_pressed)
    _cur_sort_func = "_sort_by_res"
    _resort_list()

func _sort_by_res(a, b):
    return a.get_res_num() > b.get_res_num()


func _on_dev_toggled(button_pressed: bool):
    _set_color($VCon/Option/Dev, button_pressed)
    _cur_sort_func = "_sort_by_dev"
    _resort_list()

func _sort_by_dev(a, b):
    return a.get_dev_num() > b.get_dev_num()


func _on_settlement_toggled(button_pressed: bool):
    _set_color($VCon/Option/Settlement, button_pressed)
    _cur_sort_func = "_sort_by_settlement"
    _resort_list()

func _sort_by_settlement(a, b):
    return a.get_settlement_num() > b.get_settlement_num()


func _on_city_toggled(button_pressed: bool):
    _set_color($VCon/Option/City, button_pressed)
    _cur_sort_func = "_sort_by_city"
    _resort_list()

func _sort_by_city(a, b):
    return a.get_city_num() > b.get_city_num()


func _on_vp_toggled(button_pressed:bool):
    _set_color($VCon/Option/VP, button_pressed)
    _cur_sort_func = "_sort_by_vp"
    _resort_list()

func _sort_by_vp(a, b):
    return a.get_vp_num() > b.get_vp_num()


func _resort_list():
    var item_list = []
    for item in $VCon/PlayerList.get_children().duplicate():
        item_list.append(item)
        $VCon/PlayerList.remove_child(item)
    item_list.sort_custom(self, _cur_sort_func)
    for item in item_list:
        $VCon/PlayerList.add_child(item)