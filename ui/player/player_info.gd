extends Control


# 玩家游戏中信息


var _name: String
var _order: int
var _size: int


func init(order: int, name: String, catan_size: int):
    _order = order
    _name = name
    _size = catan_size
    _init_icon()
    _init_format()
    _init_signal()


func _init_icon():
    $HBox/PlayerIcon.player_color = Data.ORDER_DATA[_order]
    $HBox/PlayerIcon.init(PlayerInfoMgr.get_info(_name))


func _init_format():
    $HBox/Grid/Road.set_format("%s/{0}".format([_get_data(Data.BuildingType.ROAD)]))
    $HBox/Grid/City.set_format("%s/{0}".format([_get_data(Data.BuildingType.CITY)]))
    $HBox/Grid/Settlement.set_format("%s/{0}".format([_get_data(Data.BuildingType.SETTLEMENT)]))


func _init_signal():
    PlayingNet.get_client().connect("assist_info_changed", self, "_on_player_assist_changed")
    PlayingNet.get_client().connect("score_info_changed", self, "_on_player_score_changed")
    PlayingNet.get_client().connect("building_info_changed", self, "_on_player_building_changed")


func _get_data(type: int):
    return Data.NUM_DATA[_size].building.each_num[type]


func _on_player_assist_changed(assist_info: Protocol.AssistInfo):
    if assist_info.player_turn_name == _name:
        $HBox/PlayerIcon.set_on_turn(true)
    else:
        $HBox/PlayerIcon.set_on_turn(false)
    $HBox/Grid/BiggestArmy.set_highlight(assist_info.biggest_name == _name)
    $HBox/Grid/LongestRoad.set_highlight(assist_info.longgest_name == _name)


func _on_player_building_changed(name: String, building_info: Protocol.PlayerBuildingInfo):
    if name == _name:
        $HBox/Grid/Settlement.set_num(len(building_info.settlement_info))
        $HBox/Grid/City.set_num(len(building_info.city_info))
        $HBox/Grid/Road.set_num(len(building_info.road_info))


func _on_player_score_changed(name: String, score_info: Protocol.PlayerScoreInfo):
    if name == _name:
        $HBox/Grid/VP.set_num(score_info.vic_point)
        $HBox/Grid/Resource.set_num(len(score_info.res_cards))
        $HBox/Grid/Card.set_num(len(score_info.dev_cards))
        $HBox/Grid/LongestRoad.set_num(score_info.continue_road)
        $HBox/Grid/BiggestArmy.set_num(score_info.army_num)