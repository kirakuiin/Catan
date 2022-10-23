extends Control

# 编辑器页面

enum DrawType {DrawTile, DrawPoint, DrawHarbor}

const Tile: PackedScene = preload("res://ui/map/tile.tscn")
const ORIGIN: Vector3 = Vector3(0, 0, 0)

onready var _tiles := {}
onready var _group := ButtonGroup.new()

var _map_info: Protocol.MapInfo = Protocol.MapInfo.new()
var _draw_type: int = DrawType.DrawTile
var _brush_val: int = Data.TileType.NULL
var _layout: Hexlib.HexLayout


func _ready():
    _create_layout_tile()
    _draw_grid()
    _init_btn()
    _init_info()


func _create_layout_tile():
    var layout_tile = Tile.instance()
    layout_tile.set_tile_info(Protocol.TileInfo.new())
    layout_tile.hide()
    $CanvasBG/OriginPoint/Grid.add_child(layout_tile)
    _layout = layout_tile.get_layout()


func _draw_grid():
    $CanvasBG/OriginPoint/Grid.layout = _layout
    $CanvasBG/OriginPoint/Grid.update()
    $CanvasBG/OriginPoint/Tile.position = $CanvasBG/OriginPoint.rect_size/2


func _init_btn():
    for btn in $Tiles/Con.get_children():
        btn.group = _group
        btn.set_callback(funcref(self, "_on_tile_changed"))
    $Tiles/Con/Mountain.activiate()
    for btn in $Point/Con.get_children():
        btn.group = _group
        btn.set_callback(funcref(self, "_on_point_changed"))
    for btn in $Harbor/Con.get_children():
        btn.group = _group
        btn.set_callback(funcref(self, "_on_harbor_changed"))
    $Info/VP/Edit.value = _map_info.victory_point


func _init_info():
    # TODO: 编辑航海家版地图
    # TODO: 更加丰富的编辑选项
    $Info/Expansion/OptionButton.add_item(UI_Data.MODE_DATA[0], 0)


func _unhandled_input(event):
    if event is InputEventMouseButton and event.is_pressed():
        var rect_pos = $CanvasBG.make_canvas_position_local(event.position)
        var pos = $CanvasBG/OriginPoint.make_canvas_position_local(event.position)
        var rect = Rect2(Vector2(0, 0), $CanvasBG.rect_size)
        if event.button_index == BUTTON_MASK_LEFT and rect.has_point(rect_pos):
            var cube = Hexlib.pixel_to_hex(_layout, pos).to_vector3()
            match _draw_type:
                DrawType.DrawTile:
                    _add_tile(cube)
                DrawType.DrawPoint:
                    _add_point(cube)
                DrawType.DrawHarbor:
                    _add_harbor(cube)


func _add_tile(pos: Vector3):
    if _brush_val == Data.TileType.NULL:
        if pos in _tiles:
            _tiles[pos].queue_free()
            _tiles.erase(pos)
    else:
        if pos in _tiles:
            _tiles[pos].queue_free()
        var tile = Tile.instance()
        tile.set_tile_info(Protocol.TileInfo.new(pos, _brush_val))
        $CanvasBG/OriginPoint/Tile.add_child(tile)
        _tiles[pos] = tile


func _add_point(pos: Vector3):
    if not pos in _tiles:
        return
    var tile_info = _tiles[pos].get_tile_info()
    if not tile_info.tile_type in [Data.TileType.OCEAN, Data.TileType.DESERT]:
        tile_info.point_type = _brush_val
        _tiles[pos].set_tile_info(tile_info)


func _add_harbor(pos: Vector3):
    if not pos in _tiles:
        return
    var tile = _tiles[pos]
    var tile_info = tile.get_tile_info()
    if tile_info.tile_type == Data.TileType.OCEAN:
        var harbor_info = tile.get_harbor_info()
        if harbor_info.harbor_type == _brush_val:
            var cur_angle = harbor_info.get_harbor_angle() + 60.0
            if cur_angle >= 180.0:
                cur_angle -= 360.0
            _tiles[pos].set_harbor_type(_brush_val, cur_angle)
        else:
            _tiles[pos].set_harbor_type(_brush_val, _layout.orientation.start_angle+30)


func _on_tile_changed(tile_type: int):
    _draw_type = DrawType.DrawTile
    _brush_val = tile_type


func _on_point_changed(point_type: int):
    _draw_type = DrawType.DrawPoint
    _brush_val = point_type


func _on_harbor_changed(harbor_type: int):
    _draw_type = DrawType.DrawHarbor
    _brush_val = harbor_type


func _on_quit_editor():
    SceneMgr.goto_scene(SceneMgr.MAIN_SCENE)


func _on_save_map():
    if $Info/File/LineEdit.text:
        _save_map()
    else:
        $SavePopup.popup_centered()


func _on_mouse_moved(relative: Vector2):
    $CanvasBG/OriginPoint.rect_position += relative


func _on_map_saved(map_name: String):
    $Info/File/LineEdit.text = map_name
    _save_map()


func _save_map():
    var file_name = $Info/File/LineEdit.text
    _generate_map_info()
    if _check_map_valid():
        SceneMgr.show_prompt("保存成功")
        MapLoader.save_map(file_name, _map_info)


func _generate_map_info():
    _map_info.origin_blueprint.clear()
    for tile in _tiles.values():
        var tile_info = tile.get_tile_info()
        var harbor_info = tile.get_harbor_info()
        _map_info.add_tile(tile_info)
        if Data.is_valid_harbor(harbor_info.harbor_type):
            _map_info.add_harbor(harbor_info)


func _check_map_valid() -> bool:
    if _map_info.has_uncertain():
        SceneMgr.show_prompt("随机数据配置有误")
        return false
    elif _map_info.has_empty_point():
        SceneMgr.show_prompt("存在未分配点数的地块")
        return false
    elif _map_info.has_wrong_harbor():
        SceneMgr.show_prompt("存在方向不正确的海港")
        return false
    else:
        return true



func _on_open_map():
    $OpenPopup.popup_centered()


func _on_map_selected(map_name: String):
    var map_info = MapLoader.get_map(map_name)
    if map_info:
        $Info/File/LineEdit.text = map_name
        _map_info_to_editor(map_info)
        $Info/VP/Edit.value = _map_info.victory_point
    else:
        SceneMgr.show_prompt("打开失败")


func _map_info_to_editor(map_info: Protocol.MapInfo):
    _clear()
    _map_info = map_info
    for tile_info in _map_info.origin_tiles.values():
        var tile = Tile.instance()
        tile.set_tile_info(tile_info)
        $CanvasBG/OriginPoint/Tile.add_child(tile)
        _tiles[tile_info.cube_pos] = tile
    for harbor_info in _map_info.origin_harbors:
        _tiles[harbor_info.cube_pos].set_harbor_type(harbor_info.harbor_type, harbor_info.get_harbor_angle())


func _clear():
    for tile in _tiles.values():
        tile.queue_free()
    _tiles = {}


func _on_edit_data():
    $DataConfig.set_map_info(_map_info)
    $DataConfig.popup_centered()


func _on_data_edit_done(map_info: Protocol.MapInfo):
    _map_info = map_info


func _on_edit_pool():
    _generate_map_info()
    $PoolConfig.set_map_info(_map_info)
    $PoolConfig.popup_centered()


func _on_pool_edit_done(map_info: Protocol.MapInfo):
    _map_info = map_info


func _on_edit_vp(value: int):
    _map_info.victory_point = value