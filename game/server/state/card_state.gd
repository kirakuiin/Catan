extends Reference

# 卡牌释放状态机

const Condition: Script = preload("res://game/server/state/conditions.gd")
const Action: Script = preload("res://game/server/state/actions.gd")


# 打出卡牌阶段
class PlayCardState:
    extends HSM.SubMachineState

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()

    func _to_string():
        return "PlayCardState[%s]" % _name

    func _init_all_state():
        _machine.state_list.append(PlayBeginState.new(self, _name))
        _machine.state_list.append(ExecuteKnightState.new(self, _name))
        _machine.state_list.append(ExecuteRoadState.new(self, _name))
        _machine.state_list.append(ExecutePlentyState.new(self, _name))
        _machine.state_list.append(ExecuteMonoState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]


# 准备阶段
class PlayBeginState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PlayBeginState[%s]" % _name

    func activiate():
        _init_transitions()

    func _init_transitions():
        var condition = Condition.PlayerOpParamCondition.new(_name, Data.CardType.KNIGHT)
        add_transition(HSM.Transition.new(get_state_in_parent(ExecuteKnightState), 0, condition))
        condition = Condition.PlayerOpParamCondition.new(_name, Data.CardType.ROAD)
        add_transition(HSM.Transition.new(get_state_in_parent(ExecuteRoadState), 0, condition))
        condition = Condition.PlayerOpParamCondition.new(_name, Data.CardType.PLENTY)
        add_transition(HSM.Transition.new(get_state_in_parent(ExecutePlentyState), 0, condition))
        condition = Condition.PlayerOpParamCondition.new(_name, Data.CardType.MONOPOLY)
        add_transition(HSM.Transition.new(get_state_in_parent(ExecuteMonoState), 0, condition))


# 结束阶段
class PlayEndState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PlayEndState[%s]" % _name

    func activiate():
        _exit_actions.append(Action.set_play_card(_name, true))
        _exit_actions.append(Action.reset_op_state(_name))
        var Turn = load("res://game/server/state/turn_state.gd")
        var has_roll_dice = Condition.HasRollDiceCondition.new()
        add_transition(HSM.Transition.new(get_state_in_parent(Turn.RollDiceState), 2, HSM.NotCondition.new(has_roll_dice)))
        add_transition(HSM.Transition.new(get_state_in_parent(Turn.BuildAndTradeState), 2, has_roll_dice))


# 骑士卡
class ExecuteKnightState:
    extends HSM.SubMachineState

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()

    func _to_string():
        return "ExecuteKnightState[%s]" % _name

    func _init_all_state():
        _machine.state_list.append(MoveRobberState.new(self, _name))
        _machine.state_list.append(RobPlayerState.new(self, _name))
        _machine.state_list.append(PlayEndState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]
        

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
        add_transition(HSM.Transition.new(get_state_in_parent(PlayEndState), 0, condition))


# 道路卡
class ExecuteRoadState:
    extends HSM.SubMachineState

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()

    func _to_string():
        return "ExecuteRoadState[%s]" % _name

    func _init_all_state():
        _machine.state_list.append(PlaceRoadState.new(self, _name))
        _machine.state_list.append(PlaceRoadState.new(self, _name))
        _machine.state_list.append(PlayEndState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]

    func get_next_state(state):
        return _machine.state_list[_machine.state_list.find(state)+1]


# 放置道路
class PlaceRoadState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PlaceRoadState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.notify_place_road(_name, false))
        _exit_actions.append(Action.reset_op_state(_name))
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(get_parent_machine().get_next_state(self), 0, condition))


# 丰年卡
class ExecutePlentyState:
    extends HSM.SubMachineState

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()

    func _to_string():
        return "ExecutePlentyState[%s]" % _name

    func _init_all_state():
        _machine.state_list.append(ChooseResState.new(self, _name))
        _machine.state_list.append(PlayEndState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]


# 选择资源状态
class ChooseResState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "ChooseResState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.notify_choose_res(_name))
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(get_state_in_parent(PlayEndState), 0, condition))


# 垄断卡
class ExecuteMonoState:
    extends HSM.SubMachineState

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()

    func _to_string():
        return "ExecuteMonoState[%s]" % _name

    func _init_all_state():
        _machine.state_list.append(ChooseMonoTypeState.new(self, _name))
        _machine.state_list.append(PlayEndState.new(self, _name))
        _machine.initial_state = _machine.state_list[0]


# 选择垄断类型状态
class ChooseMonoTypeState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "ChooseMonoTypeState[%s]" % _name

    func activiate():
        _entry_actions.append(Action.notify_choose_mono_type(_name))
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(get_state_in_parent(PlayEndState), 0, condition))