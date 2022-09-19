extends Node

# 回合状态


const Condition: Script = preload("res://game/server/conditions.gd")


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
        var orders = get_root().get_server().order_info.order_to_name.keys()
        orders.sort()
        var result = []
        for order in orders:
            result.append(get_root().get_server().order_info.order_to_name[order])
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
        _entry_actions.append(HSM.Action.new(funcref(get_root().get_server(), "update_turn_num"), []))


# 大回合结束
class OneTurnEndState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "OneTurnEndState"

    func activiate():
        var target = get_parent_machine().get_state_list()[0]
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
        _machine.state_list.append(MoveRobberState.new(self, _name))
        _machine.state_list.append(BuildAndTradeState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]

    func activiate():
        .activiate()
        _init_actions()
        _init_transitions()

    func _init_actions():
        _entry_actions.append(HSM.Action.new(funcref(get_root().get_server(), "set_cur_turn_name"), [_name]))
        _exit_actions.append(HSM.Action.new(funcref(get_root().get_server(), "change_player_state"), [_name, NetDefines.PlayerOpState.READY]))

    func _init_transitions():
        var parent = get_parent_machine()
        var state_list = parent.get_state_list()
        var target = state_list[state_list.find(self)+1]
        var condition = Condition.PlayerStateCondition.new(_name, get_root().get_server().player_state, NetDefines.PlayerOpState.PASS)
        add_transition(HSM.Transition.new(target, 0, [condition]))


# 特殊出牌阶段
class SpecialPlayCardState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "SpecialPlayCardState[%s]" % _name


# 投掷骰子阶段
class RollDiceState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "RollDiceState[%s]" % _name


# 移动强盗阶段
class MoveRobberState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "MoveRobber[%s]" % _name


# 建造交易阶段
class BuildAndTradeState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "BuildAndTradeState[%s]" % _name