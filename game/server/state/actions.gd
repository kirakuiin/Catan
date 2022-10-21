extends Node

# 行动

# 重置玩家状态
static func reset_net_state(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "reset_player_net_state"), [player_name])


# 重置玩家操作状态
static func reset_op_state(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "reset_player_op_state"), [player_name])


# 广播建筑信息
static func broadcast_building() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_building_info"), [])


# 广播银行信息
static func broadcast_bank() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_bank_info"), [])


# 广播卡牌信息
static func broadcast_cards() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_card_info"), [])


# 广播个人信息
static func broadcast_personals() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_personal_info"), [])


# 广播强盗信息
static func broadcast_robber() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_robber_pos"), [])


# 修改个人信息
static func set_play_card(player_name: String, is_play: bool) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "set_play_card_state"), [player_name, is_play])


# 通知放置定居点
static func notify_place_settlement(player_name: String, settlement_type: int) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_place_settlement"), [player_name, settlement_type])


# 通知放置道路
static func notify_place_road(player_name: String, road_type: int) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_place_road"), [player_name, road_type])


# 通知放置道路
static func notify_upgrade_city(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_upgrade_city"), [player_name])


# 通知特殊出牌
static func notify_special_play(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_special_play"), [player_name])


# 通知特殊建造
static func notify_special_building(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_special_building"), [player_name])


# 通知选择资源
static func notify_choose_res(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_choose_res"), [player_name])


# 通知选择垄断类型
static func notify_choose_mono_type(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "notify_choose_mono_type"), [player_name])


# 给予发展卡
static func give_dev_card(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "give_dev_card"), [player_name])


# 初始化资源
static func initial_res(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "initial_resource"), [player_name])


# 设置当前玩家回合
static func set_turn_name(player_name: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "set_cur_turn_name"), [player_name])


# 更新回合数
static func update_turn() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "update_turn_num"), [])


# 设置回合阶段
static func set_turn_phase(phase: String) -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "set_turn_phase"), [phase])


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


# 弹出结算画面
static func show_score_panel() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_show_score_panel"), [])


# 返回准备界面
static func exit_to_prepare() -> HSM.Action:
    return HSM.Action.new(funcref(PlayingNet.get_server(), "broadcast_exit_to_prepare"), [])