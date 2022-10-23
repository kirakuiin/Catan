extends HBoxContainer

export(Data.ResourceType) var type: int

var _map_info: Protocol.MapInfo


signal value_changed(type, value)


func _ready():
    $Icon.texture = load(UI_Data.RES_ICON_DATA[type])


func init(map_info: Protocol.MapInfo):
    _map_info = map_info
    $Edit.value = _map_info.resource_data[type]


func _on_value_changed(value: int):
    _map_info.resource_data[type] = value
    emit_signal("value_changed", type, value)
