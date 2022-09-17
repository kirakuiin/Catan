extends Node

# 初始状态逻辑

const Setup: Script = preload("res://game/server/setup_state.gd")


# 初始状态
class InitState:
    extends HSM.State 

    func _init(parent).(parent):
        pass
        
    func activiate():
        var conditions = [AllReadyCondition.new(get_root().get_server().player_state)]
        var ready = HSM.Transition.new(get_root().get_state_by_path([Setup.SetupState]), 0, conditions)
        add_transition(ready)
    
    func _to_string():
        return 'InitState'


# 玩家就绪条件
class AllReadyCondition:
    extends HSM.Condition

    var _player_state: Dictionary

    func _init(states: Dictionary):
        _player_state = states

    func is_meet_condition() -> bool:
        for state in _player_state.values():
            if state == NetDefines.PlayerOpState.NOT_READY:
                return false
        return true