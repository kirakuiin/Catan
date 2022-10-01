extends Node

# 游戏结算状态

const Condition: Script = preload("res://game/server/state/conditions.gd")
const Action: Script = preload("res://game/server/state/actions.gd")


# 游戏结束
class GameOverState:
    extends HSM.SubMachineState

    func _init(parent).(parent):
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()
    
    func _to_string():
        return 'GameOverState'

    func _init_all_state():
        _machine.state_list.append(ShowScoreState.new(self))
        _machine.state_list.append(ExitState.new(self))
        _machine.initial_state = _machine.state_list[0]


# 展示分数阶段
class ShowScoreState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "ShowScoreState"

    func activiate():
        var condition = Condition.NotExistStateCondition.new(NetDefines.PlayerNetState.WAIT_FOR_RESPONE)
        add_transition(HSM.Transition.new(get_state_in_parent(ExitState), 0, condition))
        _entry_actions.append(Action.show_score_panel())


# 退出状态
class ExitState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "ExitState"

    func activiate():
        _entry_actions.append(Action.exit_to_prepare())