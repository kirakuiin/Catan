extends Node

# 转换条件


# 永远为真
class TrueCondition:
    extends HSM.Condition

    func is_meet_condition() -> bool:
        return true


# 永远为假
class FalseCondition:
    extends HSM.Condition

    func is_meet_condition() -> bool:
        return false


# 所有玩家就绪
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


# 玩家处于指定状态
class PlayerStateCondition:
    extends HSM.Condition

    var _name: String
    var _player_state: Dictionary
    var _need_type: int

    func _init(name: String, states: Dictionary, type: int):
        _name = name
        _player_state = states
        _need_type = type 
        
    func is_meet_condition() -> bool:
        return _player_state[_name] == _need_type