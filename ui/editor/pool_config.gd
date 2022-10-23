extends PopupDialog


signal config_done(map_info)


var _map_info: Protocol.MapInfo


func set_map_info(map_info):
    _map_info = Protocol.copy(map_info)
    _init_ui()


func _init_ui():
    $HBox/Tile/Sub/Desert.init(_map_info)
    $HBox/Tile/Sub/Hill.init(_map_info)
    $HBox/Tile/Sub/Mountain.init(_map_info)
    $HBox/Tile/Sub/Pasture.init(_map_info)
    $HBox/Tile/Sub/Forest.init(_map_info)
    $HBox/Tile/Sub/Field.init(_map_info)
    $HBox/Point/Sub/Two.init(_map_info)
    $HBox/Point/Sub/Three.init(_map_info)
    $HBox/Point/Sub/Four.init(_map_info)
    $HBox/Point/Sub/Five.init(_map_info)
    $HBox/Point/Sub/Six.init(_map_info)
    $HBox/Point/Sub/Eight.init(_map_info)
    $HBox/Point/Sub/Nine.init(_map_info)
    $HBox/Point/Sub/Ten.init(_map_info)
    $HBox/Point/Sub/Eleven.init(_map_info)
    $HBox/Point/Sub/Twelve.init(_map_info)
    $HBox/Harbor/Sub/Generic.init(_map_info)
    $HBox/Harbor/Sub/Wool.init(_map_info)
    $HBox/Harbor/Sub/Lumber.init(_map_info)
    $HBox/Harbor/Sub/Brick.init(_map_info)
    $HBox/Harbor/Sub/Ore.init(_map_info)
    $HBox/Harbor/Sub/Grain.init(_map_info)
    $HBox/Tile/TileAverage.pressed = _map_info.tile_average
    $HBox/Point/PointAverage.pressed = _map_info.point_average
    _on_tile_changed(0, 0)
    _on_point_changed(0, 0)
    _on_harbor_changed(0, 0)


func _on_cancel():
    hide()


func _on_confirm():
    hide()
    emit_signal("config_done", _map_info)


func _on_tile_changed(type: int, value: int):
    var cur = _map_info.get_uncertain_tile_num()
    var total = StdLib.sum(_map_info.tile_pool.values())
    var color = Color.red if cur > total else Color.green
    color = Util.color_to_str(color)
    var result = [color, cur, total]
    $HBox/Tile/Title.bbcode_text = "[center][color=%s]地块[%d/%d][/color][/center]" % result


func _on_point_changed(type: int ,value: int):
    var cur = _map_info.get_uncertain_point_num()
    var total = StdLib.sum(_map_info.point_pool.values())
    var color = Color.red if cur > total else Color.green
    color = Util.color_to_str(color)
    var result = [color, cur, total]
    $HBox/Point/Title.bbcode_text = "[center][color=%s]点数[%d/%d][/color][/center]" % result


func _on_harbor_changed(type: int, value: int):
    var cur = _map_info.get_uncertain_harbor_num()
    var total = StdLib.sum(_map_info.harbor_pool.values())
    var color = Color.red if cur > total else Color.green
    color = Util.color_to_str(color)
    var result = [color, cur, total]
    $HBox/Harbor/Title.bbcode_text = "[center][color=%s]海港[%d/%d][/color][/center]" % result

func _on_tile_ave(is_pressed: bool):
    _map_info.tile_average = is_pressed


func _on_point_ave(is_pressed: bool):
    _map_info.point_average = is_pressed