extends Node2D


# 游戏世界


func _ready():
	$Map/ViewContainer/Viewport/DragArea.connect("mouse_moved", self, "_on_mouse_moved")


# 初始化世界
func init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
	$Map/ViewContainer/Viewport/CatanMap.init_with_mapinfo(map)
	$UIOverlay/Overlay.init(order, setup.catan_size)


func _on_mouse_moved(offset: Vector2):
	var camera = $Map/ViewContainer/Viewport/Camera
	camera.offset -= offset
	var diff = $Map/ViewContainer/Viewport/CatanMap.get_map_size()-$Map/ViewContainer.rect_size
	camera.offset.x = max(min(diff.x/2, camera.offset.x), -diff.x/2)
	camera.offset.y = max(min(diff.y/2, camera.offset.y), -diff.y/2)
