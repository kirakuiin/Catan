extends Node

# 游戏结算状态


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

    func get_name_list(is_reverse: bool=false) -> Array:
        var result = []
        for order in get_root().get_server().order_info.order_to_name:
            result.append(get_root().get_server().order_info.order_to_name[order])
        return result


# 展示分数阶段
class ShowScoreState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "ShowScoreState"


# 退出状态
class ExitState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "ExitState"
