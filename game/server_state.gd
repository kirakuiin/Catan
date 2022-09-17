extends Node


# 服务端状态


# 服务端状态机
class CatanStateMachine:
    extends HSM.StateMachine 

    var _server_ref: WeakRef
    var _setup_state: SetupState
    var _turn_state: TurnState
    var _gameover_state: GameOverState

    func _init(server):
        _server_ref = weakref(server)

    func _init_all_state():
        pass

    func get_server():
        return _server_ref.get_ref()


# 状态基类
class CatanState:
    extends HSM.State 

    func get_server():
        var parent = get_parent_machine()
        while parent and parent.get_parent_machine():
            parent = parent.get_parent_machine()
        return parent.get_server()


class CatanSubMachine:
    extends HSM.SubMachineState


# 初始状态
class InitState:
    extends CatanState

    func _to_string():
        return 'InitState'


# 玩家初始化
class SetupState:
    extends HSM.SubMachineState

    func _to_string():
        return 'SetupState'


class SetupSettlementState:
    extends CatanState

    func _to_string():
        return 'SetupSettlementState'


class SetupPlaceRoadState:
    extends CatanState

    func _to_string():
        return 'SetupRoadState'


# 玩家回合
class TurnState:
    extends HSM.SubMachineState

    func _to_string():
        return 'TurnState'


class CheckPointState:
    extends CatanState

    func _to_string():
        return 'CheckPointState'


class PlayCardState:
    extends CatanState

    func _to_string():
        return 'PlayCardState'


class RoleDiceState:
    extends CatanState

    func _to_string():
        return 'RoleDiceState'


class TradeAndBuildState:
    extends CatanState

    func _to_string():
        return 'TradeAndBuildState'


# 游戏结束
class GameOverState:
    extends HSM.SubMachineState

    func _to_string():
        return 'GameOverState'


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