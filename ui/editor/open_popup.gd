extends PopupDialog


# 地图保存弹窗


signal map_selected(map_name)

var _map_name: String
var _cur_index: int


func _on_confirm():
    if _map_name:
        emit_signal("map_selected", _map_name)
    hide()
    $ScrollContainer/ItemList.unselect_all()


func _on_cancel():
    hide()
    $ScrollContainer/ItemList.unselect_all()


func _on_item_selected(index: int):
    _map_name = $ScrollContainer/ItemList.get_item_text(index)
    _cur_index = index


func _on_delete():
    if _map_name:
        MapLoader.remove_map(_map_name)
        $ScrollContainer/ItemList.remove_item(_cur_index)
        _map_name = ""

func _on_show():
    $ScrollContainer/ItemList.clear()
    var name_list = MapLoader.get_custom()
    for name in name_list:
        $ScrollContainer/ItemList.call_deferred("add_item", name)
