extends Node2D


# 游戏世界


const Client: Script = preload("res://game/client/logic.gd")
const Server: Script = preload("res://game/server/logic.gd")

var _client: Client
var _server: Server


func _ready():
	$Map/ViewContainer/Viewport/DragArea.connect("mouse_moved", self, "_on_mouse_moved")


func _exit_tree():
	Audio.play_bg()


# 初始化世界
func init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
	if GameServer.is_server():
		_init_server(order, setup, map)
	_init_client(order, setup, map)
	_init_map(map, setup)
	_init_overlay()
	_client.start()
	_init_signal()
	Audio.stop_bg()


func _init_server(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
	_server = Server.new(order, setup, map)
	self.add_child(_server)


func _init_client(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
	_client = Client.new(order, setup, map)
	self.add_child(_client)


func _init_map(map: Protocol.MapInfo, setup: Protocol.CatanSetupInfo):
	$Map/ViewContainer/Viewport/CatanMap.init_with_mapinfo(map, setup.is_enable_fog)


func _init_overlay():
	$UIOverlay/Overlay.init()


func _init_signal():
	_client.connect("stat_info_received", self, "_on_show_stat")
	_client.connect("exit_game", self, "_on_exit_game")


func _on_show_stat(stat_info: Protocol.StatInfo):
	$Score/ScorePopup.init(stat_info)
	$Score/ScorePopup.popup_centered()


func _on_exit_game():
	SceneMgr.close_pop_scene()


func _on_mouse_moved(offset: Vector2):
	var camera = $Map/ViewContainer/Viewport/Camera
	camera.offset -= offset
	var diff = $Map/ViewContainer/Viewport/CatanMap.get_map_size()-$Map/ViewContainer.rect_size
	camera.offset.x = max(min(diff.x/2, camera.offset.x), -diff.x/2)
	camera.offset.y = max(min(diff.y/2, camera.offset.y), -diff.y/2)