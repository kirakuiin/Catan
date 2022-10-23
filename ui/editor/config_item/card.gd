extends HBoxContainer

export(Data.CardType) var type: int

var _map_info: Protocol.MapInfo


signal value_changed(type, value)


func _ready():
    $Label.text = UI_Data.CARD_NAME[type]


func init(map_info: Protocol.MapInfo):
    _map_info = map_info
    $Edit.value = _map_info.card_data[type]


func _on_value_changed(value: int):
    _map_info.card_data[type] = value
    emit_signal("value_changed", type, value)
