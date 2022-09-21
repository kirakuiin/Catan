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
            if state == NetDefines.PlayerState.NOT_READY:
                return false
        return true


# 玩家处于指定状态
class PlayerStateCondition:
    extends HSM.Condition

    var _name: String
    var _player_state: Dictionary
    var _need_type: String

    func _init(name: String, states: Dictionary, type: String):
        _name = name
        _player_state = states
        _need_type = type 
        
    func is_meet_condition() -> bool:
        return _player_state[_name] == _need_type
    
    
# 玩家发展卡数量为0
class DevCardEqualZeroCondition:
    extends HSM.Condition

    var _name: String
    var _scores: Dictionary

    func _init(player_name: String, scores_info: Dictionary):
        _name = player_name
        _scores = scores_info

    func is_meet_condition() -> bool:
        return len(_scores[_name].dev_cards) == 0


# 骰子数为7
class DiceEqualSevenCondition:
    extends HSM.Condition

    var _dice: WeakRef

    func _init(dice):
        _dice = weakref(dice)

    func is_meet_condition() -> bool:
        return _dice.get_ref().get_last_num() == Data.PointType.SEVEN


# 骰子数不为7
class DiceNotEqualSevenCondition:
    extends HSM.Condition

    var _cond: HSM.Condition

    func _init(dice):
        _cond = DiceEqualSevenCondition.new(dice)

    func is_meet_condition() -> bool:
        return not _cond.is_meet_condition()
