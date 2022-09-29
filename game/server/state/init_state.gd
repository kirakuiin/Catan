extends Node

# 初始状态逻辑

const Setup: Script = preload("res://game/server/state/setup_state.gd")
const Condition: Script = preload("res://game/server/state/conditions.gd")
const Action: Script = preload("res://game/server/state/actions.gd")


# 初始状态
class InitState:
    extends HSM.State 

    func _init(parent).(parent):
        pass
        
    func activiate():
        _exit_actions.append(Action.broadcast_building())
        _exit_actions.append(Action.broadcast_bank())
        _exit_actions.append(Action.broadcast_cards())
        _exit_actions.append(Action.broadcast_personals())
        _exit_actions.append(Action.broadcast_robber())
        var condition = Condition.AllReadyCondition.new()
        var state = get_state_in_parent(Setup.SetupState)
        var ready = HSM.Transition.new(state, 0, condition)
        add_transition(ready)
    
    func _to_string():
        return 'InitState'