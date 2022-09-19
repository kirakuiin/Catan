extends Control

# 地块表现

var _tile_info: Protocol.TileInfo
onready var _layout: Hexlib.HexLayout = Hexlib.HexLayout.new(Hexlib.Flat(), rect_size/2)


func _ready():
	_init_texture()
	_init_pos()


func set_tile_info(tile_info: Protocol.TileInfo):
	_tile_info = tile_info


func set_harbor_type(type: int, angle: float):
	$Point/HarborTexture.texture = ResourceLoader.load(Data.HARBOR_DATA[type])
	$Point/BridgeTexture.rect_pivot_offset = $Point/HarborTexture.rect_size/2
	$Point/BridgeTexture.rect_rotation = angle
	$Point/BridgeTexture.show()
	if type == Data.HarborType.GENERIC:
		$Point/RatioLabel31.show()
	else:
		$Point/RatioLabel21.show()


func set_point_visible(is_visible: bool):
	$Point.visible = is_visible


func _init_texture():
	$TileTexture.texture = ResourceLoader.load(Data.TILE_DATA[_tile_info.tile_type])
	if not _tile_info.tile_type in [Data.TileType.DESERT, Data.TileType.OCEAN]:
		$Point/NumberTexture.texture = ResourceLoader.load(Data.POINT_DATA[_tile_info.point_type])


func _init_pos():
	var hex := Hexlib.Hex.new()
	hex.from_vector3(_tile_info.cube_pos)
	var center := Hexlib.hex_to_pixel(_layout, hex)
	Util.set_center(self, center)


func get_layout() -> Hexlib.HexLayout:
	return _layout