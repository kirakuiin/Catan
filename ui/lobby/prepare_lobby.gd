extends Control

# 准备大厅


const PlayerItem: PackedScene = preload("res://ui/lobby/player_item.tscn")
const MapGenerator: Script = preload("res://game/map/generator.gd")


var _host_info: Protocol.HostInfo
var _catan_setup_info: Protocol.CatanSetupInfo
var _map_info: Protocol.MapInfo
var _order_info: Protocol.PlayerOrderInfo


func _init():
	_host_info = Protocol.HostInfo.new(GameConfig.get_player_name(),
			GameConfig.get_icon_id(), 1, Data.CatanSize.SMALL, Data.HostState.PREPARE)
	_catan_setup_info = Protocol.CatanSetupInfo.new(Data.CatanSize.SMALL)


func _ready():
	_init_option()
	_init_player_list()
	_init_signal()
	_init_broadcast()
	_init_btn()
	_generate_map()
	_init_catan_setup()


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed == true:
			$CatanMap.hide()


func _init_option():
	_init_basic_option()
	_init_mode_option()
	if GameServer.is_server():
		_init_special_option()
	else:
		$Option/Special.hide()


func _init_basic_option():
	for index in UI_Data.MAPSIZE_DATA:
		var desc = "%s-%s人" % [UI_Data.MAPSIZE_DATA[index]-1, UI_Data.MAPSIZE_DATA[index]]
		$Option/Basic/Scroll/VCon/PlayerNumContainer/Btn.add_item(desc, index)
	for index in UI_Data.SWITCH_DATA:
		$Option/Basic/Scroll/VCon/FogContainer/Btn.add_item(UI_Data.SWITCH_DATA[index], index)
		$Option/Basic/Scroll/VCon/RandResourceContainer/Btn.add_item(UI_Data.SWITCH_DATA[index], index)
		$Option/Basic/Scroll/VCon/RandSeatContainer/Btn.add_item(UI_Data.SWITCH_DATA[index], index)
	for index in UI_Data.MODE_DATA:
		$Option/Basic/Scroll/VCon/ExpansionMode/Btn.add_item(UI_Data.MODE_DATA[index], index)


func _init_mode_option():
	for index in UI_Data.SEAFARER_MAP_DATA:
		$Option/Seafarer/Scroll/VCon/Map/Btn.add_item(UI_Data.SEAFARER_MAP_DATA[index], index)
	for index in UI_Data.SWITCH_DATA:
		$Option/Settler/Scroll/VCon/RandLandContainer/Btn.add_item(UI_Data.SWITCH_DATA[index], index)
	if GameServer.is_server():
		var maps = [""] + MapLoader.get_map_list()
		for index in len(maps):
			$Option/Settler/Scroll/VCon/Map/Btn.add_item(maps[index], index)
	else:
		$Option/Settler/Scroll/VCon/Map/Btn.hide()
		$Option/Settler/Scroll/VCon/Map/Name.show()


func _init_special_option():
	$Option/Special/Scroll.show()
	for index in UI_Data.SWITCH_DATA:
		$Option/Special/Scroll/VCon/DIYDev/Btn.add_item(UI_Data.SWITCH_DATA[index], index)


func _init_player_list():
	for player_info in PlayerInfoMgr.get_all_info():
		_add_player_item(player_info)


func _add_player_item(player_info: Protocol.PlayerInfo):
	_clear_item()
	var infos = PlayerInfoMgr.get_all_info()
	infos.sort_custom(self, "_custom_sort")
	for info in infos:
		var item = PlayerItem.instance()
		item.init(info)
		$PlayerBg/PlayerContainer.add_child(item)


func _clear_item():
	for child in Array($PlayerBg/PlayerContainer.get_children()):
		child.free()


func _custom_sort(a: Protocol.PlayerInfo, b: Protocol.PlayerInfo) -> bool:
	return a.peer_id < b.peer_id


func _init_signal():
	PlayerInfoMgr.connect("player_added", self, "_on_player_added")
	PlayerInfoMgr.connect("player_removed", self, "_on_player_removed")
	GameServer.connect("server_disconnected", self, "_on_server_disconnected")
	if GameServer.is_server():
		ConnState.connect("state_changed", self, "_on_conn_state_changed")
		$PlayerSeat.connect("all_player_ready", self, "_on_all_player_ready")


func _init_broadcast():
	if GameServer.is_server():
		$BroadcastTimer.start()


func _init_btn():
	if not GameServer.is_server():
		$StartBtn.hide()
	else:
		$PlayerSeat/PreviewBtn.text = "生成"


func _init_catan_setup():
	if not GameServer.is_server():
		rpc("send_catan_init_info", GameServer.get_peer_id())


master func send_catan_init_info(peer_id: int):
	rpc_id(peer_id, "recv_catan_setup_info", Protocol.serialize(_catan_setup_info))
	rpc_id(peer_id, "recv_map_info", Protocol.serialize(_map_info))
	rpc_id(peer_id, "recv_host_info", Protocol.serialize(_host_info))
	rpc_id(peer_id, "recv_done")


puppet func recv_catan_setup_info(net_data):
	_catan_setup_info = Protocol.deserialize(net_data) as Protocol.CatanSetupInfo
	_reset_catan_setup()


puppet func recv_host_info(net_data):
	_host_info = Protocol.deserialize(net_data)


puppet func recv_done():
	if _host_info.host_state == Data.HostState.PLAYING:
		rpc("reconnect", Protocol.serialize(PlayerInfoMgr.get_self_info()))


master func reconnect(net_data):
	var player_info = Protocol.deserialize(net_data)
	Log.get_logger(Log.LogModule.CONN).logi("玩家[%s]请求重连." % player_info.player_name)
	rpc_id(player_info.peer_id, "start_game", Protocol.serialize(_order_info), Protocol.serialize(_catan_setup_info), Protocol.serialize(_map_info), true)


func _reset_catan_setup():
	var info = _catan_setup_info
	$Option/Basic/Scroll/VCon/ExpansionMode/Btn.select(info.mode_idx())
	$Option/Basic/Scroll/VCon/PlayerNumContainer/Btn.select(int(info.catan_size!=Data.CatanSize.SMALL))
	$Option/Basic/Scroll/VCon/FogContainer/Btn.select(int(info.is_enable_fog))
	$Option/Basic/Scroll/VCon/RandResourceContainer/Btn.select(int(info.is_random_resource))
	$Option/Basic/Scroll/VCon/RandSeatContainer/Btn.select(int(info.is_random_order))
	_reset_mode_setup()


func _reset_mode_setup():
	var info = _catan_setup_info
	if info.is_settler():
		_reset_settler()
	elif info.is_seafarer():
		_reset_seafarer()


func _reset_settler():
	var info = _catan_setup_info
	$Option/Seafarer.hide()
	$Option/Settler.show()
	$Option/Settler/Scroll/VCon/RandLandContainer/Btn.select(int(info.expansion_mode.is_random_land))
	$Option/Special/Scroll/VCon/WinVP/Edit.value = Data.SETTLER_DATA[info.catan_size]["vic_point"]
	if GameServer.is_server():
		if not info.expansion_mode.selected_map:
			$Option/Settler/Scroll/VCon/Map/Btn.select(0)
	else:
		$Option/Settler/Scroll/VCon/Map/Name.text = info.expansion_mode.selected_map


func _reset_seafarer():
	var info = _catan_setup_info
	$Option/Settler.hide()
	$Option/Seafarer.show()
	$Option/Seafarer/Scroll/VCon/Map/Btn.select(info.expansion_mode.selected_map)
	$Option/Special/Scroll/VCon/WinVP/Edit.value = Data.SEAFARER_DATA[info.catan_size][info.expansion_mode.selected_map]["vic_point"]


func _on_change_num(index):
	rpc("change_max_player_num", index)


remotesync func change_max_player_num(index: int):
	_catan_setup_info.catan_size = UI_Data.MAPSIZE_DATA[index]
	_host_info.max_player_num = UI_Data.MAPSIZE_DATA[index]
	ConnState.set_max_conn(_host_info.max_player_num-1)
	_reset_catan_setup()
	_generate_map()


func _on_change_fog(index: int):
	rpc("change_fog_state", index)


remotesync func change_fog_state(index: int):
	_catan_setup_info.is_enable_fog = bool(index)
	_reset_catan_setup()


func _on_change_order(index: int):
	rpc("change_order_state", index)


remotesync func change_order_state(index: int):
	_catan_setup_info.is_random_order = bool(index)
	_reset_catan_setup()


func _on_change_resource(index: int):
	rpc("change_resource_state", index)


remotesync func change_resource_state(index: int):
	_catan_setup_info.is_random_resource = bool(index)
	_reset_catan_setup()


func _on_change_mode(index: int):
	rpc("change_mode_state", index)


remotesync func change_mode_state(index: int):
	_catan_setup_info.change_mode_by_idx(index)
	_reset_catan_setup()
	_generate_map()


func _on_change_land(index: int):
	rpc("change_land_state", index)


remotesync func change_land_state(index: int):
	_catan_setup_info.expansion_mode.is_random_land = bool(index)
	_reset_catan_setup()


func _on_change_sea_map(index: int):
	rpc("change_sea_map", index)


remotesync func change_sea_map(index: int):
	_catan_setup_info.expansion_mode.selected_map = index
	_reset_catan_setup()


func _on_change_custom_map(index: int):
	var maps = MapLoader.get_map_list()
	_catan_setup_info.expansion_mode.selected_map = maps[index-1] if index != 0 else ""
	rpc("change_custom_map", _catan_setup_info.expansion_mode.selected_map)
	_generate_map()


remotesync func change_custom_map(map_name: String):
	_catan_setup_info.expansion_mode.selected_map = map_name
	_reset_catan_setup()


func _on_player_added(player_info: Protocol.PlayerInfo):
	_add_player_item(player_info)
	_host_info.cur_player_num += 1


func _on_player_removed(player_info: Protocol.PlayerInfo):
	for item in $PlayerBg/PlayerContainer.get_children():
		if item.get_player_name() == player_info.player_name:
			item.free()
			break
	_host_info.cur_player_num -= 1


func _on_broadcast():
	GameServer.broadcast(Protocol.serialize(_host_info))


func _on_exit_prepare():
	SceneMgr.goto_scene(SceneMgr.LOBBY_SCENE)
	GameServer.close_game()


func _on_server_disconnected():
	_on_exit_prepare()
	SceneMgr.show_prompt("网络连接中断")


func _on_all_player_ready(is_ready: bool):
	if is_ready:
		$StartBtn.disabled = false
	else:
		$StartBtn.disabled = true


func _on_start_game():
	_order_info = $PlayerSeat.get_order_info()
	if _catan_setup_info.is_random_order:
		_randomize_order(_order_info)
	start_game(Protocol.serialize(_order_info), Protocol.serialize(_catan_setup_info), Protocol.serialize(_map_info), false)


func _randomize_order(order_info: Protocol.PlayerOrderInfo):
	var orders = order_info.order_to_name.keys()
	var names = order_info.order_to_name.values()
	orders.shuffle()
	names.shuffle()
	for idx in range(len(orders)):
		order_info.order_to_name[orders[idx]] = names[idx]


remote func start_game(order_data, setup_data, map_data, is_reconnect: bool):
	var scene = SceneMgr.pop_scene(SceneMgr.WORLD_SCENE)
	var order_info = Protocol.deserialize(order_data)
	var setup_info = Protocol.deserialize(setup_data)
	var map_info = Protocol.deserialize(map_data)
	scene.init(order_info, setup_info, map_info, is_reconnect)


func _on_conn_state_changed(state):
	if state == Data.HostState.PLAYING:
		rpc("start_game", Protocol.serialize(_order_info), Protocol.serialize(_catan_setup_info), Protocol.serialize(_map_info), false)
	_host_info.host_state = state


func _generate_map():
	if GameServer.is_server():
		if _catan_setup_info.is_settler() and _catan_setup_info.expansion_mode.selected_map:
			_map_info = MapLoader.get_map(_catan_setup_info.expansion_mode.selected_map)
		else:
			var generator := MapGenerator.new()
			_map_info = generator.generate(_catan_setup_info)
		rpc("recv_map_info", Protocol.serialize(_map_info))


remote func recv_map_info(data):
	_map_info = Protocol.deserialize(data) as Protocol.MapInfo
	if $CatanMap.visible:
		_on_preview_map()


func _on_preview_map():
	_generate_map()
	$CatanMap.show_preview(_map_info, _catan_setup_info.is_enable_fog)
	$CatanMap.rect_pivot_offset = rect_size/2
	$CatanMap.show()


func _on_vp_value_changed(value: float):
	_catan_setup_info.win_vp = int(value)


func _on_res_value_changed(value: float):
	_catan_setup_info.initial_res = int(value)


func _on_enable_diy_dev(index: int):
	_catan_setup_info.custom_dev = bool(index)
