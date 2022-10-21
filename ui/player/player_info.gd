extends Control


# 玩家游戏中信息


var _name: String
var _order: int
var _setup: Protocol.CatanSetupInfo


func init(order: int, name: String, setup: Protocol.CatanSetupInfo):
    _order = order
    _name = name
    _setup = setup
    _init_icon()
    _init_format()
    _init_signal()


func _ready():
    _init_particle()


func _init_icon():
    $HBox/PlayerIcon.player_color = UI_Data.ORDER_DATA[_order]
    $HBox/PlayerIcon.init(PlayerInfoMgr.get_info(_name))


func _init_format():
    $HBox/Grid/Road.set_format("%s/{0}".format([_get_data(Data.BuildingType.ROAD)]))
    $HBox/Grid/City.set_format("%s/{0}".format([_get_data(Data.BuildingType.CITY)]))
    $HBox/Grid/Settlement.set_format("%s/{0}".format([_get_data(Data.BuildingType.SETTLEMENT)]))
    $HBox/Grid/VP.set_format("%s/{0}".format([_setup.win_vp]))


func _init_signal():
    PlayingNet.get_client().connect("assist_info_changed", self, "_on_player_assist_changed")
    PlayingNet.get_client().connect("card_info_changed", self, "_on_player_card_changed")
    PlayingNet.get_client().connect("building_info_changed", self, "_on_player_building_changed")
    PlayingNet.get_client().connect("personal_info_changed", self, "_on_player_personal_changed")
    PlayingNet.get_client().connect("notification_received", self, "_on_receive_notification")
    PlayerInfoMgr.connect("player_removed", self, "_on_player_removed")
    PlayerInfoMgr.connect("player_added", self, "_on_player_added")


func _init_particle():
    $Particles2D.visibility_rect = Rect2(-rect_size/2, rect_size)
    $Particles2D.position = rect_size/2
    $Particles2D.process_material.emission_box_extents = Vector3(rect_size.x/2, rect_size.y/2, 0)


func _get_data(type: int):
    return Data.SETTLER_DATA[_setup.catan_size].building.each_num[type]


func get_order_num() -> int:
    return _order


func get_vp_num() -> int:
    return _get_client().player_personals[_name].vic_point-_get_vp_card_num(_name)


func get_res_num() -> int:
    return StdLib.sum(_get_client().player_cards[_name].res_cards.values())


func get_dev_num() -> int:
    return StdLib.sum(_get_client().player_cards[_name].dev_cards.values())


func get_city_num() -> int:
    return len(_get_client().player_buildings[_name].city_info)


func get_settlement_num() -> int:
    return len(_get_client().player_buildings[_name].settlement_info)


func _on_player_assist_changed(assist_info: Protocol.AssistInfo):
    var is_on_turn = assist_info.player_turn_name == _name
    _set_on_turn(is_on_turn)
    $HBox/PlayerIcon.set_on_turn(is_on_turn)
    $HBox/Grid/BiggestArmy.set_highlight(assist_info.biggest_name == _name)
    $HBox/Grid/LongestRoad.set_highlight(assist_info.longgest_name == _name)
    if assist_info.turn_phase != NetDefines.TurnPhase.SPECIAL_BUILDING:
        $Particles2D.emitting = false


func _set_on_turn(is_on_turn: bool):
    if is_on_turn:
        $AnimationPlayer.play("on_turn")
    else:
        $AnimationPlayer.play("RESET")


func _on_player_building_changed(name: String, building_info: Protocol.PlayerBuildingInfo):
    if name == _name:
        $HBox/Grid/Settlement.set_num(len(building_info.settlement_info))
        $HBox/Grid/City.set_num(len(building_info.city_info))
        $HBox/Grid/Road.set_num(len(building_info.road_info))


func _on_player_card_changed(name: String, card_info: Protocol.PlayerCardInfo):
    if name == _name:
        $HBox/Grid/Resource.set_num(StdLib.sum(card_info.res_cards.values()))
        $HBox/Grid/Card.set_num(StdLib.sum(card_info.dev_cards.values()))


func _on_player_personal_changed(name: String, personal_info: Protocol.PlayerPersonalInfo):
    if name == _name:
        $HBox/Grid/LongestRoad.set_num(personal_info.continue_road)
        $HBox/Grid/BiggestArmy.set_num(personal_info.army_num)
        var vp = personal_info.vic_point
        if _name != _get_client().get_name():
            vp -= _get_vp_card_num(_name)
        $HBox/Grid/VP.set_num(vp)

func _get_vp_card_num(player_name):
    return StdLib.dict_get(_get_client().player_cards[player_name].dev_cards, Data.CardType.VP, 0)


func _on_player_removed(player_info):
    if player_info.player_name == _name:
        $HBox/PlayerIcon.modulate = Color(0.3, 0.3, 0.3)


func _on_player_added(player_info):
    if player_info.player_name == _name:
        $HBox/PlayerIcon.modulate = Color.white


func _on_receive_notification(noti: Protocol.NotificationInfo):
    if noti.notify_type == NetDefines.NotificationType.SPECIAL_BUILDING:
        if _name == noti.notify_params.player:
            $Particles2D.emitting = true
        else:
            $Particles2D.emitting = false


func _get_client():
    return PlayingNet.get_client()