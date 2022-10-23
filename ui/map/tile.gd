extends Control

# 地块表现

var _tile_info: Protocol.TileInfo
var _harbor_info: Protocol.HarborInfo = Protocol.HarborInfo.new()
onready var _layout: Hexlib.HexLayout = Hexlib.HexLayout.new(Hexlib.Flat(), rect_size/2)


func _ready():
	_init_pos()
	_init_particle()


func get_layout() -> Hexlib.HexLayout:
	return _layout


func init_signal():
	PlayingNet.get_client().connect("dice_changed", self, "_on_dice_changed")


func set_tile_info(tile_info: Protocol.TileInfo):
	_tile_info = tile_info
	_init_texture()


func get_tile_info() -> Protocol.TileInfo:
	return _tile_info


func get_harbor_info() -> Protocol.HarborInfo:
	return _harbor_info


func set_harbor_type(type: int, angle: float):
	_set_harbor_info(type, angle)
	if type == Data.HarborType.NULL:
		$Point/Harbor.hide()
	else:
		$Point/Harbor.show()
		$Point/Harbor/HarborTexture.texture = ResourceLoader.load(UI_Data.HARBOR_DATA[type])
		$Point/Harbor/BridgeTexture.rect_pivot_offset = $Point/Harbor/HarborTexture.rect_size/2
		$Point/Harbor/BridgeTexture.rect_rotation = angle
		if type == Data.HarborType.GENERIC:
			$Point/Harbor/RatioLabel31.show()
			$Point/Harbor/RatioLabel21.hide()
		elif type == Data.HarborType.RANDOM:
			$Point/Harbor/RatioLabel21.hide()
			$Point/Harbor/RatioLabel31.hide()
		else:
			$Point/Harbor/RatioLabel21.show()
			$Point/Harbor/RatioLabel31.hide()


func _set_harbor_info(type: int, angle: float):
	_harbor_info.harbor_type = type
	_harbor_info.cube_pos = _tile_info.cube_pos
	var self_hex = Hexlib.create_hex(_tile_info.cube_pos)
	for hex in Hexlib.get_hex_adjacency_hex(self_hex):
		if abs(Hexlib.hex_relative_angle(self_hex, hex)-angle) < 1:
			_harbor_info.near_pos = hex.to_vector3()


func set_point_visible(is_visible: bool):
	$Point.visible = is_visible


func _init_texture():
	if Data.is_valid_tile(_tile_info.tile_type):
		$TileTexture.texture = ResourceLoader.load(UI_Data.TILE_DATA[_tile_info.tile_type])
	else:
		$TileTexture.texture = null
	if _tile_info.point_type != Data.PointType.ZERO:
		$Point/NumberTexture.texture = ResourceLoader.load(UI_Data.POINT_DATA[_tile_info.point_type])
	else:
		$Point/NumberTexture.texture = null


func _init_pos():
	var hex := _tile_info.to_hex()
	var center := Hexlib.hex_to_pixel(_layout, hex)
	Util.set_center(self, center)


func _init_particle():
	$Particles2D.visibility_rect = Rect2(-rect_size/2, rect_size)
	$Particles2D.position = rect_size/2
	$Particles2D.process_material.emission_ring_radius = rect_size.x/2-10
	$Particles2D.process_material.emission_ring_inner_radius = rect_size.x/2-20


func _on_dice_changed(info: Array):
	yield(get_tree().create_timer(NetDefines.ROLL_TIME), "timeout")
	if info[0] + info[1] == _tile_info.point_type:
		$Point/NumberTexture.modulate = Color.aqua
		_play_particle()
	else:
		$Point/NumberTexture.modulate = Color.white


func _play_particle():
	$Particles2D.emitting = true
	yield(get_tree().create_timer(NetDefines.ROLL_TIME), "timeout")
	$Particles2D.emitting = false
