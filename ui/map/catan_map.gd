extends Control


# 卡坦地图ui表示


const Tile: PackedScene = preload("res://ui/map/tile.tscn")

var _map: Protocol.MapInfo


func _ready():
    pass


func init_with_mapinfo(map: Protocol.MapInfo):
    _map = map
    draw_map()


func draw_map():
    clear_all()
    for tile_info in _map.grid_map.values():
        var tile = Tile.instance()
        tile.set_tile_info(tile_info)
        $Center.add_child(tile)


func clear_all():
    for child in $Center.get_children():
        $Center.remove_child(child)


func set_all_point_visible(is_visible: bool):
    for child in $Center.get_children():
        child.set_point_visible(is_visible)
