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


# 不存在某种状态
class NotExistStateCondition:
    extends HSM.Condition

    var _state: String

    func _init(state: String):
        _state = state

    func is_meet_condition() -> bool:
        for state in PlayingNet.get_server().player_state.values():
            if state == _state:
                return false
        return true


# 所有玩家就绪
class AllReadyCondition:
    extends HSM.Condition

    var _cond: HSM.Condition

    func _init():
        _cond = NotExistStateCondition.new(NetDefines.PlayerState.NOT_READY)

    func is_meet_condition() -> bool:
        return _cond.is_meet_condition()


# 玩家处于指定状态
class PlayerStateCondition:
    extends HSM.Condition

    var _name: String
    var _need_state: String

    func _init(name: String, state: String):
        _name = name
        _need_state = state
        
    func is_meet_condition() -> bool:
        return PlayingNet.get_server().player_state[_name] == _need_state
    
    
# 玩家发展卡数量为0
class DevCardEqualZeroCondition:
    extends HSM.Condition

    var _name: String

    func _init(player_name: String):
        _name = player_name

    func is_meet_condition() -> bool:
        return len(PlayingNet.get_server().player_scores[_name].dev_cards) == 0


# 骰子数为7
class DiceEqualSevenCondition:
    extends HSM.Condition

    func is_meet_condition() -> bool:
        return PlayingNet.get_server().dice.get_last_num() == Data.PointType.SEVEN


# 骰子数不为7
class DiceNotEqualSevenCondition:
    extends HSM.Condition

    var _cond: HSM.Condition

    func _init():
        _cond = DiceEqualSevenCondition.new()

    func is_meet_condition() -> bool:
        return not _cond.is_meet_condition()
