extends Control

# 地块表现

var _tile_info: Protocol.TileInfo
onready var _layout: Hexlib.HexLayout = Hexlib.HexLayout.new(Hexlib.Flat(), rect_size/2)


func _ready():
	_init_texture()
	_init_pos()


func set_tile_info(tile_info: Protocol.TileInfo):
	_tile_info = tile_info


func set_point_visible(is_visible: bool):
	$NumberTexture.visible = is_visible


func _init_texture():
	$TileTexture.texture = ResourceLoader.load(Data.TILE_DATA[_tile_info.tile_type])
	if _tile_info.tile_type != Data.TileType.DESERT:
		$NumberTexture.texture = ResourceLoader.load(Data.POINT_DATA[_tile_info.point_type])


func _init_pos():
	var hex := Hexlib.Hex.new()
	hex.from_vector3(_tile_info.cube_pos)
	var center := Hexlib.hex_to_pixel(_layout, hex)
	Util.set_center(self, center)
