extends Node


# 服务端状态


# 初始状态
class InitState:
    extends HSM.State


# 玩家初始化
class SetupState:
    extends HSM.SubMachineState


# 玩家回合
class TurnState:
    extends HSM.SubMachineState


# 游戏结束
class GameOverState:
    extends HSM.SubMachineState



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