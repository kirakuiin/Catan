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


func _init_icon():
    $HBox/PlayerIcon.player_color = Data.ORDER_DATA[_order]
    $HBox/PlayerIcon.init(PlayerInfoMgr.get_info(_name))


func _init_format():
    $HBox/Grid/Road.set_format("%s/{0}".format([_get_data(Data.BuildingType.ROAD)]))
    $HBox/Grid/City.set_format("%s/{0}".format([_get_data(Data.BuildingType.CITY)]))
    $HBox/Grid/Settlement.set_format("%s/{0}".format([_get_data(Data.BuildingType.SETTLEMENT)]))


func _get_data(type: int):
    return Data.NUM_DATA[_size].building.each_num[type]