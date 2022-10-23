extends HBoxContainer

export(Data.TileType) var type: int

var _map_info: Protocol.MapInfo


signal value_changed(type, value)


func _ready():
    $Icon.texture = load(UI_Data.TILE_DATA[type])


func init(map_info: Protocol.MapInfo):
    _map_info = map_info
    $Edit.value = _map_info.tile_pool[type]


func _on_value_changed(value: int):
    _map_info.tile_pool[type] = value
    emit_signal("value_changed", type, value)
