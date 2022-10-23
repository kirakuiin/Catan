extends PopupDialog


signal config_done(map_info)


var _map_info: Protocol.MapInfo


func set_map_info(map_info):
    _map_info = Protocol.copy(map_info)
    _init_ui()


func _init_ui():
    $HBox/Resource/Wool.init(_map_info)
    $HBox/Resource/Brick.init(_map_info)
    $HBox/Resource/Ore.init(_map_info)
    $HBox/Resource/Lumber.init(_map_info)
    $HBox/Resource/Grain.init(_map_info)
    $HBox/Card/Scroll/VCon/Knight.init(_map_info)
    $HBox/Card/Scroll/VCon/Mono.init(_map_info)
    $HBox/Card/Scroll/VCon/Road.init(_map_info)
    $HBox/Card/Scroll/VCon/VP.init(_map_info)
    $HBox/Card/Scroll/VCon/Year.init(_map_info)
    $HBox/Building/City.init(_map_info)
    $HBox/Building/Settlement.init(_map_info)
    $HBox/Building/Road.init(_map_info)


func _on_cancel():
    hide()


func _on_confirm():
    hide()
    emit_signal("config_done", _map_info)
