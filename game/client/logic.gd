extends Node


# 游戏中客户端


signal assist_info_changed(assist_info)  # 辅助信息改变
signal building_info_changed(player_name, building_info)  # 建筑信息改变
signal score_info_changed(player_name, score_info)  # 得分信息改变
signal client_state_changed(state)  # 客户端状态改变
signal dice_changed(info)  # 骰子变化
signal robber_pos_changed(pos)  # 强盗位置变化


var map_info: Protocol.MapInfo
var order_info: Protocol.PlayerOrderInfo
var setup_info: Protocol.CatanSetupInfo

var assist_info: Protocol.AssistInfo
var player_buildings: Dictionary
var player_scores: Dictionary

var point_info: StdLib.Set

var client_state: String  # 客户端状态


func _init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    order_info = order
    setup_info = setup
    map_info = map
    assist_info = Protocol.AssistInfo.new()
    player_buildings = {}
    player_scores = {}
    client_state = NetDefines.ClientState.IDLE
    _init_point_info()


func _init_point_info():
    point_info = StdLib.Set.new()
    for tile_info in map_info.grid_map.values():
        if tile_info.tile_type != Data.TileType.OCEAN:
            var hex = tile_info.to_hex()
            for corner in Hexlib.get_all_corner(hex):
                point_info.add(corner.to_vector3())


func _ready():
    _init_node_setup()
    Log.logi("[client]游戏客户端启动...")


func _init_node_setup():
    name = NetDefines.CLIENT_NAME
    add_to_group(NetDefines.CLIENT_NAME)

# Pub


# 启动客户端
func start():
    PlayingNet.rpc("client_ready", get_name())


func get_name() -> String:
    return PlayerInfoMgr.get_self_info().player_name


# 获得所有的可放置点位
func get_available_point() -> Array:
    var result = []
    var all_used_point = _get_all_used_point()
    var not_used_point = point_info.diff(all_used_point)
    for point in not_used_point.values():
        var neighbor = StdLib.Set.new()
        var corners = Hexlib.get_adjacency_corner(Hexlib.create_corner(point))
        for corner in corners:
            neighbor.add(corner.to_vector3())
        if neighbor.intersect(all_used_point).size() == 0:
            result.append(point)
    return result

func _get_all_used_point() -> StdLib.Set:
    var all_used_point := []
    for building in player_buildings.values():
        all_used_point.append_array(building.settlement_info)
        all_used_point.append_array(building.city_info)
    return StdLib.Set.new(all_used_point)


# 获得布置阶段所有的可放置道路
func get_setup_available_road() -> Array:
    var result = []
    var roads = _get_road_from_corner(player_buildings[get_name()].settlement_info[-1])
    for tuple in roads.values():
        result.append(Protocol.create_road(tuple))
    return result

func _get_road_from_corner(pos: Vector3) -> StdLib.Set:
        var result = StdLib.Set.new()
        var begin = Hexlib.create_corner(pos)
        for end in Hexlib.get_adjacency_corner(begin):
            if _is_valid_land_corner(end):
                result.add(Protocol.RoadInfo.new(begin.to_vector3(), end.to_vector3()).to_tuple())
        return result

func _is_valid_land_corner(corner: Hexlib.Corner) -> bool:
    for hex in Hexlib.get_corner_adjacency_hex(corner):
        var cube_pos = hex.to_vector3()
        if cube_pos in map_info.grid_map and map_info.grid_map[cube_pos].tile_type != Data.TileType.OCEAN:
            return true
    return false


# 获得回合阶段所有的可放置道路
func get_turn_available_road() -> Array:
    var result = []
    return result


# 设置客户端状态
func change_client_state(state: String):
    client_state = state
    Log.logd("[client]客户端状态变为 '%s'" % [state])
    emit_signal("client_state_changed", client_state)


# C2S


# 放置定居点完毕
func place_settlement_done(pos: Vector3):
    PlayingNet.rpc("place_settlement_done", get_name(), pos)
    change_client_state(NetDefines.ClientState.IDLE)


# 放置道路完毕
func place_road_done(road: Protocol.RoadInfo):
    PlayingNet.rpc("place_road_done", get_name(), Protocol.serialize(road))
    change_client_state(NetDefines.ClientState.IDLE)


# 让过回合
func pass_turn():
    Log.logd("[client]玩家[%s]让过回合" % get_name())
    PlayingNet.rpc("pass_turn", get_name())
    change_client_state(NetDefines.ClientState.IDLE)


# S2C


# 放置定居点
func place_settlement():
    change_client_state(NetDefines.ClientState.PLACE_SETTLEMENT)


# 放置道路
func place_road(is_setup: bool):
    change_client_state(NetDefines.ClientState.PLACE_ROAD_SETUP if is_setup else NetDefines.ClientState.PLACE_ROAD_TURN)


# 修改辅助信息
func change_assist_info(info: Protocol.AssistInfo):
    Log.logd("[client]辅助信息变化[%s]" % info)
    assist_info = info
    emit_signal("assist_info_changed", info)


# 更新骰子
func change_dice(info: Array):
    Log.logd("[client]骰子变化[%d, %d]" % info)
    emit_signal("dice_changed", info)


# 初始化玩家的建筑信息
func init_building_info(building_infos: Dictionary):
    Log.logd("[client]建筑信息初始化[%s]" % [building_infos])
    player_buildings = building_infos
    for name in building_infos:
        emit_signal("building_info_changed", name, building_infos[name])


# 初始化玩家的分数信息
func init_score_info(score_infos: Dictionary):
    Log.logd("[client]分数信息初始化[%s]" % [score_infos])
    player_scores = score_infos
    for name in score_infos:
        emit_signal("score_info_changed", name, score_infos[name])


# 修改指定玩家的建筑信息
func change_building_info(player_name: String, building_info: Protocol.PlayerBuildingInfo):
    Log.logd("[client]玩家[%s]的建筑信息改变[%s]" % [player_name, building_info])
    player_buildings[player_name] = building_info
    emit_signal("building_info_changed", player_name, building_info)


# 修改指定玩家的分数信息
func change_score_info(player_name: String, score_info: Protocol.PlayerScoreInfo):
    Log.logd("[client]玩家[%s]的分数信息改变[%s]" % [player_name, score_info])
    player_scores[player_name] = score_info
    emit_signal("score_info_changed", player_name, score_info)


# 修改强盗位置
func change_robber_pos(pos: Vector3):
    Log.logd("[client]强盗移动至[%s]" % str(pos))
    emit_signal("robber_pos_changed", pos)


# 自由行动阶段
func into_free_action():
    change_client_state(NetDefines.ClientState.FREE_ACTION)