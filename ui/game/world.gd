extends Node2D


# 游戏世界


const Client: Script = preload("res://game/client/logic.gd")
const Server: Script = preload("res://game/server/logic.gd")

const ZOOM_UNIT := Vector2(0.05, 0.05)
const ZOOM_MAX := 0.65
const ZOOM_MIN := 1.45

var _client: Client
var _server: Server


func _ready():
	Audio.play_game_bg()


func _exit_tree():
	Audio.play_bg()
	if GameServer.is_server():
		ConnState.to_prepare()


# 初始化世界
func init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo, is_reconnect: bool):
	if GameServer.is_server():
		_init_server(order, setup, map)
	_init_client(order, setup, map)
	_init_map(map, setup)
	_init_overlay()
	_init_signal()
	if is_reconnect:
		_client.reconnect()
	else:
		_client.start()
	_show_rule()


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


func _show_rule():
	$Popup/RulePopup.init_popup()
	if $Popup/RulePopup.have_rule():
		_on_show_rule()


func _init_signal():
	_client.connect("stat_info_received", self, "_on_show_stat")
	_client.connect("exit_game", self, "_on_exit_game")


func _on_show_stat(stat_info: Protocol.StatInfo):
	$Map/ViewContainer/Viewport/DragArea.set_enable(false)
	$Popup/ScorePopup.init(stat_info)
	$Popup/ScorePopup.popup_centered()


func _on_exit_game():
	SceneMgr.close_pop_scene()


func _on_show_setting():
	$Popup/SettingPopup.popup_centered()
	$Map/ViewContainer/Viewport.gui_disable_input = true


func _on_hide():
	$Map/ViewContainer/Viewport.gui_disable_input = false


func _on_show_rule():
	$Popup/RulePopup.popup_centered()
	$Map/ViewContainer/Viewport.gui_disable_input = true



func _on_mouse_moved(offset: Vector2):
	var camera = $Map/ViewContainer/Viewport/Camera
	camera.offset -= offset
	var diff = $Map/ViewContainer/Viewport/CatanMap.get_map_size()-$Map/ViewContainer.rect_size*camera.zoom
	camera.offset.x = max(min(diff.x/2, camera.offset.x), -diff.x/2)
	camera.offset.y = max(min(diff.y/2, camera.offset.y), -diff.y/2)


func _on_wheel_up():
	var camera = $Map/ViewContainer/Viewport/Camera
	if camera.zoom.x >= ZOOM_MAX:
		camera.zoom -= ZOOM_UNIT


func _on_wheel_down():
	var camera = $Map/ViewContainer/Viewport/Camera
	if camera.zoom.x <= ZOOM_MIN:
		camera.zoom += ZOOM_UNIT
