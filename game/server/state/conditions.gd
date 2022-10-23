extends Node

# 转换条件


# 不存在某种状态
class NotExistStateCondition:
    extends HSM.Condition

    var _state: String
    var _check: bool

    func _init(state: String, check_offline: bool=true):
        _state = state
        _check = check_offline

    func is_meet_condition() -> bool:
        var states = PlayingNet.get_server().player_net_state
        for name in states:
            if not _check and not PlayerInfoMgr.has_player(name):
                continue
            if states[name] == _state:
                return false
        return true


# 所有玩家就绪
class AllReadyCondition:
    extends HSM.Condition

    var _cond: HSM.Condition

    func _init():
        _cond = NotExistStateCondition.new(NetDefines.PlayerNetState.NOT_READY)

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
        return PlayingNet.get_server().player_net_state[_name] == _need_state


# 玩家操作处于指定状态
class PlayerOpStateCondition:
    extends HSM.Condition

    var _name: String
    var _need_state: String

    func _init(name: String, state: String):
        _name = name
        _need_state = state
        
    func is_meet_condition() -> bool:
        return PlayingNet.get_server().player_op_state[_name].state == _need_state


# 玩家操作参数处于指定状态
class PlayerOpParamCondition:
    extends HSM.Condition

    var _name: String
    var _param_idx: int
    var _param_value

    func _init(name: String, value, idx: int=0):
        _name = name
        _param_idx = idx
        _param_value = value
        
    func is_meet_condition() -> bool:
        return PlayingNet.get_server().player_op_state[_name].params[_param_idx] == _param_value
    
    
# 玩家发展卡数量为0
class DevCardEqualZeroCondition:
    extends HSM.Condition

    var _name: String

    func _init(player_name: String):
        _name = player_name

    func is_meet_condition() -> bool:
        return StdLib.sum(PlayingNet.get_server().player_cards[_name].dev_cards.values()) == 0


# 骰子数为7
class DiceEqualSevenCondition:
    extends HSM.Condition

    func is_meet_condition() -> bool:
        return PlayingNet.get_server().dice.get_last_num() == Data.PointType.SEVEN


# 玩家剩余道路数量
class PlayerRoadNumCondition:
    extends HSM.Condition

    var _name: String
    var _num: int

    func _init(player_name: String, num: int):
        _name = player_name
        _num = num

    func is_meet_condition() -> bool:
        var server = PlayingNet.get_server()
        var cur_num = len(server.player_buildings[_name].road_info)
        var max_num = PlayingNet.get_server().map_info.building_data[Data.BuildingType.ROAD]
        return max_num-cur_num == _num


# 玩家没有剩余道路
class PlayerNoRoadCondition:
    extends HSM.Condition

    var _cond: HSM.Condition

    func _init(player_name: String):
        _cond = PlayerRoadNumCondition.new(player_name, 0)

    func is_meet_condition() -> bool:
        return _cond.is_meet_condition()


# 玩家还剩余一条道路
class PlayerOneRoadCondition:
    extends HSM.Condition

    var _cond: HSM.Condition

    func _init(player_name: String):
        _cond = PlayerRoadNumCondition.new(player_name, 1)

    func is_meet_condition() -> bool:
        return _cond.is_meet_condition()


# 胜利条件
class WinCondtion:
    extends HSM.Condition

    var _name: String

    func _init(player_name: String):
        _name = player_name

    func is_meet_condition() -> bool:
        return PlayingNet.get_server().player_personals[_name].vic_point >= PlayingNet.get_server().map_info.victory_point


# 回合阶段条件
class TurnPhaseCondtion:
    extends HSM.Condition

    var _phase: String

    func _init(need_phase: String):
        _phase = need_phase

    func is_meet_condition() -> bool:
        return PlayingNet.get_server().assist_info.turn_phase == _phase