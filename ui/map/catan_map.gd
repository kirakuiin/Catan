extends Control


# 卡坦地图ui表示


const Tile: PackedScene = preload("res://ui/map/tile.tscn")

var _map: Protocol.MapInfo
var _tile_map: Dictionary = {}


func _ready():
    pass


func init_with_mapinfo(map: Protocol.MapInfo):
    _map = map
    draw_map()


func draw_map():
    clear_all()
    _draw_base()
    _draw_harbor()


func _draw_base():
    for tile_info in _map.grid_map.values():
        var tile = Tile.instance()
        tile.set_tile_info(tile_info)
        $Center.add_child(tile)
        _tile_map[tile_info.cube_pos] = tile


func _draw_harbor():
    for harbor_info in _map.harbor_list:
        _tile_map[harbor_info.cube_pos].set_harbor_type(harbor_info.harbor_type, harbor_info.harbor_angle)


func clear_all():
    for child in $Center.get_children():
        $Center.remove_child(child)
    _tile_map.clear()


func set_all_point_visible(is_visible: bool):
    for child in $Center.get_children():
        child.set_point_visible(is_visible)
