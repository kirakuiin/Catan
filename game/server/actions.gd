extends Node

# 行动

# 重置玩家状态
static func reset_state(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "reset_player_state"), [player_name])


# 广播建筑信息
static func broadcast_building() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_building_info"), [])


# 广播分数信息
static func broadcast_scores() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_score_info"), [])


# 广播强盗信息
static func broadcast_robber() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_robber_pos"), [])


# 通知放置定居点
static func notify_place_settlement(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_place_settlement"), [player_name])


# 通知放置道路
static func notify_place_road(player_name: String, is_setup: bool) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_place_road"), [player_name, is_setup])


# 初始化资源
static func initial_res(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "initial_resource"), [player_name])


# 设置当前玩家回合
static func set_turn_name(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "set_cur_turn_name"), [player_name])


# 更新回合数
static func update_turn() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "update_turn_num"), [])


# 投掷骰子
static func roll_dice() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "roll_dice"), [])


# 延迟
static func delay(time: float) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "delay"), [time])


# 丢弃资源
static func discard_res() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "discard_resource"), [])


# 移动强盗
static func move_robber(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_move_robber"), [player_name])


# 抢劫玩家
static func rob_player(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_rob_player"), [player_name])


# 分配资源
static func dispatch_res() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "dispatch_resource"), [])


# 通知自由行动
static func notify_free_action(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_free_action"), [player_name])