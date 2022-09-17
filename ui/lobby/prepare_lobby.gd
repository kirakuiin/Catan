extends Control

# 准备大厅


const PlayerItem: PackedScene = preload("res://ui/lobby/player_item.tscn")
const MapGenerator: Script = preload("res://game/map_generator.gd")


var _host_info: Protocol.HostInfo
var _catan_setup_info: Protocol.CatanSetupInfo
var _map_info: Protocol.MapInfo
var _order_info: Protocol.PlayerOrderInfo


func _init():
	_host_info = Protocol.HostInfo.new(PlayerConfig.get_player_name(),
			PlayerConfig.get_icon_id(), 1, Data.CatanSize.SMALL, Data.HostState.PREPARE)
	_catan_setup_info = Protocol.CatanSetupInfo.new(Data.CatanSize.SMALL)


func _ready():
	_init_option()
	_init_player_list()
	_init_signal()
	_init_broadcast()
	_init_catan_setup()
	_init_btn()
	_generate_map()


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed == true:
			$CatanMap.hide()


func _init_option():
	for index in Data.MAPSIZE_DATA:
		var desc = "%s-%s人" % [Data.MAPSIZE_DATA[index]-1, Data.MAPSIZE_DATA[index]]
		$OptionContainer/PlayerNumContainer/Btn.add_item(desc, index)
	for index in Data.SWITCH_DATA:
		$OptionContainer/FogContainer/Btn.add_item(Data.SWITCH_DATA[index], index)
		$OptionContainer/RandResourceContainer/Btn.add_item(Data.SWITCH_DATA[index], index)
		$OptionContainer/RandSeatContainer/Btn.add_item(Data.SWITCH_DATA[index], index)
		$OptionContainer/RandLandContainer/Btn.add_item(Data.SWITCH_DATA[index], index)


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
	GameServer.connect("server_disconnected", self, "_on_exit_prepare")
	ConnState.connect("state_changed", self, "_on_start_client_game")
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


puppet func recv_catan_setup_info(net_data):
	_catan_setup_info = Protocol.deserialize(net_data) as Protocol.CatanSetupInfo
	_reset_catan_setup()


func _reset_catan_setup():
	var info = _catan_setup_info
	$OptionContainer/PlayerNumContainer/Btn.select(int(info.catan_size!=Data.CatanSize.SMALL))
	$OptionContainer/FogContainer/Btn.select(int(info.is_enable_fog))
	$OptionContainer/RandResourceContainer/Btn.select(int(info.is_random_resource))
	$OptionContainer/RandSeatContainer/Btn.select(int(info.is_random_order))
	$OptionContainer/RandLandContainer/Btn.select(int(info.is_random_land))


func _on_change_num(index):
	rpc("change_max_player_num", index)


remotesync func change_max_player_num(index: int):
	_catan_setup_info.catan_size = Data.MAPSIZE_DATA[index]
	_host_info.max_player_num = Data.MAPSIZE_DATA[index]
	ConnState.set_max_conn(_host_info.max_player_num-1)
	_reset_catan_setup()


func _on_change_fog(index: int):
	rpc("change_fog_state", index)


remotesync func change_fog_state(index: int):
	_catan_setup_info.is_enable_fog = bool(index)
	_reset_catan_setup()


func _on_change_land(index: int):
	rpc("change_land_state", index)


remotesync func change_land_state(index: int):
	_catan_setup_info.is_random_land = bool(index)
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


func _on_all_player_ready(is_ready: bool):
	if is_ready:
		$StartBtn.disabled = false
	else:
		$StartBtn.disabled = true


func _on_start_game():
	_order_info = $PlayerSeat.get_order_info()
	if _catan_setup_info.is_random_order:
		_randomize_order(_order_info)
	start_game(Protocol.serialize(_order_info), Protocol.serialize(_catan_setup_info), Protocol.serialize(_map_info))


func _randomize_order(order_info: Protocol.PlayerOrderInfo):
	var orders = order_info.order_to_name.keys()
	var names = order_info.order_to_name.values()
	orders.shuffle()
	names.shuffle()
	for idx in range(len(orders)):
		order_info.order_to_name[orders[idx]] = names[idx]


remote func start_game(order_data, setup_data, map_data):
	var scene = SceneMgr.pop_scene(SceneMgr.WORLD_SCENE)
	var order_info = Protocol.deserialize(order_data)
	var setup_info = Protocol.deserialize(setup_data)
	var map_info = Protocol.deserialize(map_data)
	scene.init(order_info, setup_info, map_info)


func _on_start_client_game(state):
	if state == Data.HostState.PLAYING:
		rpc("start_game", Protocol.serialize(_order_info), Protocol.serialize(_catan_setup_info), Protocol.serialize(_map_info))


func _generate_map():
	if GameServer.is_server():
		var generator := MapGenerator.new()
		_map_info = generator.generate(_catan_setup_info)
		rpc("recv_map_info", Protocol.serialize(_map_info))


remote func recv_map_info(data):
	_map_info = Protocol.deserialize(data) as Protocol.MapInfo
	if $CatanMap.visible:
		_on_preview_map()


func _on_preview_map():
	_generate_map()
	$CatanMap.init_with_mapinfo(_map_info)
	$CatanMap.show()
	if _catan_setup_info.is_enable_fog:
		$CatanMap.set_all_point_visible(false)
