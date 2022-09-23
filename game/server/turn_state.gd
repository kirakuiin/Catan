extends Node

# 回合状态


const Condition: Script = preload("res://game/server/conditions.gd")
const Action: Script = preload("res://game/server/actions.gd")


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
        var condition = Condition.TrueCondition.new()
        add_transition(HSM.Transition.new(target, 0, [condition]))
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
        var condition = Condition.TrueCondition.new()
        add_transition(HSM.Transition.new(target, 0, [condition]))


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
        _machine.state_list.append(SpecialPlayCardState.new(self, _name))
        _machine.state_list.append(RollDiceState.new(self, _name))
        _machine.state_list.append(DispatchResourceState.new(self, _name))
        _machine.state_list.append(DiscardResourceState.new(self, _name))
        _machine.state_list.append(MoveRobberState.new(self, _name))
        _machine.state_list.append(BuildAndTradeState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]

    func activiate():
        .activiate()
        _init_actions()

    func _init_actions():
        _entry_actions.append(Action.set_turn_name(_name))
        _exit_actions.append(Action.reset_state(_name))

    func get_next_state():
        var parent = get_parent_machine()
        var state_list = parent.get_state_list()
        var target = state_list[state_list.find(self)+1]
        return target


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
        var condition = Condition.DevCardEqualZeroCondition.new(_name)
        add_transition(HSM.Transition.new(get_state_in_parent(RollDiceState), 0, [condition]))


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
        add_transition(HSM.Transition.new(robber, 0, [Condition.DiceEqualSevenCondition.new()]))
        var dispatch = get_state_in_parent(DispatchResourceState)
        add_transition(HSM.Transition.new(dispatch, 0, [Condition.DiceNotEqualSevenCondition.new()]))


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
        var conditions = [Condition.NotExistStateCondition.new(NetDefines.PlayerState.WAIT_FOR_RESPONE)]
        add_transition(HSM.Transition.new(get_state_in_parent(MoveRobberState), 0, conditions))


# 移动强盗阶段
class MoveRobberState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "MoveRobberState[%s]" % _name

    func activiate():
        add_transition(HSM.Transition.new(get_state_in_parent(BuildAndTradeState), 0, [Condition.TrueCondition.new()]))


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
        add_transition(HSM.Transition.new(get_state_in_parent(BuildAndTradeState), 0, [Condition.TrueCondition.new()]))


# 建造交易阶段
class BuildAndTradeState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "BuildAndTradeState[%s]" % _name

    func activiate():
        var target = get_parent_machine().get_next_state()
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerState.PASS)
        add_transition(HSM.Transition.new(target, 1, [condition]))
        _entry_actions.append(Action.notify_free_action(_name))