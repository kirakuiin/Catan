extends HBoxContainer

export(Data.BuildingType) var type: int
export(int) var min_num: int = 2


var _map_info: Protocol.MapInfo


signal value_changed(type, value)


func _ready():
    $Icon.texture = load(UI_Data.BUILDING_ICON_DATA[type])
    $Edit.min_value = min_num


func init(map_info: Protocol.MapInfo):
    _map_info = map_info
    $Edit.value = _map_info.building_data[type]


func _on_value_changed(value: int):
    _map_info.building_data[type] = value
    emit_signal("value_changed", type, value)
