extends Node2D


# 游戏世界


const Client: Script = preload("res://game/client/logic.gd")
const Server: Script = preload("res://game/server/logic.gd")

var _client: Client
var _server: Server


func _ready():
	$Map/ViewContainer/Viewport/DragArea.connect("mouse_moved", self, "_on_mouse_moved")


# 初始化世界
func init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
	$Map/ViewContainer/Viewport/CatanMap.init_with_mapinfo(map)
	$UIOverlay/Overlay.init(order, setup.catan_size)
	_init_server(order, setup, map)
	_init_client()


func _init_server(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
	_server = Server.new(order, setup, map)
	self.add_child(_server)


func _init_client():
	_client = Client.new()
	self.add_child(_client)


func _on_mouse_moved(offset: Vector2):
	var camera = $Map/ViewContainer/Viewport/Camera
	camera.offset -= offset
	var diff = $Map/ViewContainer/Viewport/CatanMap.get_map_size()-$Map/ViewContainer.rect_size
	camera.offset.x = max(min(diff.x/2, camera.offset.x), -diff.x/2)
	camera.offset.y = max(min(diff.y/2, camera.offset.y), -diff.y/2)
