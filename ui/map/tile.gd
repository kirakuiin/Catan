extends Control

# 地块表现

export(int, 0, 6) var a: int = Data.TileType.DESERT


func _ready():
	$TileTexture.texture = ResourceLoader.load(Data.TILE_DATA[a])
