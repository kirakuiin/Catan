extends Node

# 初始状态逻辑

const Setup: Script = preload("res://game/server/setup_state.gd")
const Condition: Script = preload("res://game/server/conditions.gd")


# 初始状态
class InitState:
    extends HSM.State 

    func _init(parent).(parent):
        pass
        
    func activiate():
        var conditions = [Condition.AllReadyCondition.new(get_root().get_server().player_state)]
        var ready = HSM.Transition.new(get_root().get_state_by_path([Setup.SetupState]), 0, conditions)
        add_transition(ready)
        _exit_actions.append(HSM.Action.new(funcref(get_root().get_server(), "broadcast_building_info"), []))
        _exit_actions.append(HSM.Action.new(funcref(get_root().get_server(), "broadcast_score_info"), []))
        _exit_actions.append(HSM.Action.new(funcref(get_root().get_server(), "broadcast_robber_pos"), []))
    
    func _to_string():
        return 'InitState'