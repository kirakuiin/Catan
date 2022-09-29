extends Node

# 回合状态


const Condition: Script = preload("res://game/server/state/conditions.gd")
const Action: Script = preload("res://game/server/state/actions.gd")
const Card: Script = preload("res://game/server/state/card_state.gd")


# 大回合状态
class TurnState:
    extends HSM.SubMachineState

    func _init(parent).(parent):
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()
    
    func _to_string():
        return 'TurnState'

    func _init_all_state():
        _machine.state_list.append(OneTurnBeginState.new(self))
        for name in get_name_list():
            _machine.state_list.append(PlayerTurnState.new(self, name))
        _machine.state_list.append(OneTurnEndState.new(self))
        _machine.initial_state = _machine.state_list[0]

    func get_name_list() -> Array:
        var orders = PlayingNet.get_server().order_info.order_to_name.keys()
        orders.sort()
        var result = []
        for order in orders:
            result.append(PlayingNet.get_server().order_info.order_to_name[order])
        return result


# 大回合开始
class OneTurnBeginState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "OneTurnBeginState"

    func activiate():
        var target = get_parent_machine().get_state_list()[1]
        add_transition(HSM.Transition.new(target, 0, HSM.TrueCondition.new()))
        _entry_actions.append(Action.update_turn())


# 大回合结束
class OneTurnEndState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "OneTurnEndState"

    func activiate():
        var target = get_state_in_parent(OneTurnBeginState)
        add_transition(HSM.Transition.new(target, 0, HSM.TrueCondition.new()))


# 玩家回合状态
class PlayerTurnState:
    extends HSM.SubMachineState

    var _name: String

    func _init(parent, player_name: String).(parent):
        _machine = HSM.StateMachine.new(parent)
        _name = player_name
        _init_all_state()
    
    func _to_string():
        return 'PlayerTurnState[%s]' % _name

    func _init_all_state():
        # TODO: 实现分数计算
        _machine.state_list.append(PrepareState.new(self, _name))
        _machine.state_list.append(SpecialPlayCardState.new(self, _name))
        _machine.state_list.append(RollDiceState.new(self, _name))
        _machine.state_list.append(DispatchResourceState.new(self, _name))
        _machine.state_list.append(DiscardResourceState.new(self, _name))
        _machine.state_list.append(MoveRobberState.new(self, _name))
        _machine.state_list.append(RobPlayerState.new(self, _name))
        _machine.state_list.append(BuildAndTradeState.new(self, _name))
        _machine.state_list.append(PlaceSettlementState.new(self, _name))
        _machine.state_list.append(PlaceRoadState.new(self, _name))
        _machine.state_list.append(UpgradeCityState.new(self, _name))
        _machine.state_list.append(BuyDevCardState.new(self, _name))
        _machine.state_list.append(Card.PlayCardState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]

    func activiate():
        .activiate()
        _init_actions()

    func _init_actions():
        _entry_actions.append(Action.set_turn_name(_name))
        _entry_actions.append(Action.set_play_card(_name, false))
        _exit_actions.append(Action.reset_net_state(_name))

    func get_next_state():
        var parent = get_parent_machine()
        var state_list = parent.get_state_list()
        var target = state_list[state_list.find(self)+1]
        return target


# 准备阶段
class PrepareState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PrepareState[%s]" % _name

    func activiate():
        _init_transitions()

    func _init_transitions():
        var equal_zero = Condition.DevCardEqualZeroCondition.new(_name)
        add_transition(HSM.Transition.new(get_state_in_parent(RollDiceState), 0, equal_zero))
        var not_equal = HSM.NotCondition.new(equal_zero)
        add_transition(HSM.Transition.new(get_state_in_parent(SpecialPlayCardState), 0, not_equal))


# 特殊出牌阶段
class SpecialPlayCardState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "SpecialPlayCardState[%s]" % _name

    func activiate():
        _init_transitions()

    func _init_transitions():
        _entry_actions.append(Action.notify_special_play(_name))
        _exit_actions.append(Action.reset_net_state(_name))
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.PASS)
        add_transition(HSM.Transition.new(get_state_in_parent(RollDiceState), 0, condition))
        condition = Condition.PlayerOpStateCondition.new(_name, NetDefines.PlayerOpState.PLAY_CARD)
        add_transition(HSM.Transition.new(get_state_in_parent(Card.PlayCardState), 0, condition))


# 投掷骰子阶段
class RollDiceState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "RollDiceState[%s]" % _name

    func activiate():
        _init_transitions()
        _entry_actions.append(Action.roll_dice())
        _entry_actions.append(Action.delay(NetDefines.ROLL_TIME))

    func _init_transitions():
        var robber = get_state_in_parent(DiscardResourceState)
        add_transition(HSM.Transition.new(robber, 0, Condition.DiceEqualSevenCondition.new()))
        var dispatch = get_state_in_parent(DispatchResourceState)
        add_transition(HSM.Transition.new(dispatch, 0, HSM.NotCondition.new(Condition.DiceEqualSevenCondition.new())))


# 丢弃资源阶段
class DiscardResourceState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "DiscardResourceState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.discard_res())
        var condition = Condition.NotExistStateCondition.new(NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
        add_transition(HSM.Transition.new(get_state_in_parent(MoveRobberState), 0, condition))


# 移动强盗阶段
class MoveRobberState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "MoveRobberState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.move_robber(_name))
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(get_state_in_parent(RobPlayerState), 0, condition))


# 抢夺玩家阶段
class RobPlayerState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "RobPlayerState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.rob_player(_name))
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(get_state_in_parent(BuildAndTradeState), 0, condition))


# 分发资源阶段
class DispatchResourceState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "DispatchResourceState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.dispatch_res())
        add_transition(HSM.Transition.new(get_state_in_parent(BuildAndTradeState), 0, HSM.TrueCondition.new()))


# 建造交易阶段
class BuildAndTradeState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "BuildAndTradeState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.notify_free_action(_name))
        _init_end_transition()
        _init_settlement_transition()
        _init_road_transition()
        _init_city_transition()
        _init_buy_transition()
        _init_play_transition()

    func _init_end_transition():
        var target = get_parent_machine().get_next_state()
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.PASS)
        add_transition(HSM.Transition.new(target, 1, condition))

    func _init_settlement_transition():
        var target = get_state_in_parent(PlaceSettlementState)
        var condition = Condition.PlayerOpStateCondition.new(_name, NetDefines.PlayerOpState.BUILD_SETTLEMENT)
        add_transition(HSM.Transition.new(target, 0, condition))

    func _init_road_transition():
        var target = get_state_in_parent(PlaceRoadState)
        var condition = Condition.PlayerOpStateCondition.new(_name, NetDefines.PlayerOpState.BUILD_ROAD)
        add_transition(HSM.Transition.new(target, 0, condition))

    func _init_city_transition():
        var target = get_state_in_parent(UpgradeCityState)
        var condition = Condition.PlayerOpStateCondition.new(_name, NetDefines.PlayerOpState.UPGRADE_CITY)
        add_transition(HSM.Transition.new(target, 0, condition))

    func _init_buy_transition():
        var target = get_state_in_parent(BuyDevCardState)
        var condition = Condition.PlayerOpStateCondition.new(_name, NetDefines.PlayerOpState.BUY_DEV_CARD)
        add_transition(HSM.Transition.new(target, 0, condition))

    func _init_play_transition():
        var target = get_state_in_parent(Card.PlayCardState)
        var condition = Condition.PlayerOpStateCondition.new(_name, NetDefines.PlayerOpState.PLAY_CARD)
        add_transition(HSM.Transition.new(target, 0, condition))


# 放置定居点阶段
class PlaceSettlementState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PlaceSettlementState[%s]" % _name

    func activiate():
        var target = get_state_in_parent(BuildAndTradeState)
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(target, 0, condition))
        _entry_actions.append(Action.notify_place_settlement(_name, false))
        _exit_actions.append(Action.reset_op_state(_name))


# 放置道路阶段
class PlaceRoadState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PlaceRoadState[%s]" % _name

    func activiate():
        var target = get_state_in_parent(BuildAndTradeState)
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(target, 0, condition))
        _entry_actions.append(Action.notify_place_road(_name, false))
        _exit_actions.append(Action.reset_op_state(_name))


# 升级城市阶段
class UpgradeCityState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "UpgradeCityState[%s]" % _name

    func activiate():
        var target = get_state_in_parent(BuildAndTradeState)
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(target, 0, condition))
        _entry_actions.append(Action.notify_upgrade_city(_name))
        _exit_actions.append(Action.reset_op_state(_name))


# 购买卡牌阶段
class BuyDevCardState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "BuyDevCardState[%s]" % _name

    func activiate():
        var target = get_state_in_parent(BuildAndTradeState)
        add_transition(HSM.Transition.new(target, 0, HSM.TrueCondition.new()))
        _entry_actions.append(Action.give_dev_card(_name))
        _exit_actions.append(Action.reset_op_state(_name))