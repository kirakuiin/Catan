extends Node


# 服务端状态


const Init: Script = preload("res://game/server/init_state.gd")
const Setup: Script = preload("res://game/server/setup_state.gd")
const Turn: Script = preload("res://game/server/turn_state.gd")
const GameOver: Script = preload("res://game/server/gameover_state.gd")


# 服务端状态机
class CatanStateMachine:
    extends HSM.StateMachine 

    func _init(server).(null):
        _init_all_state()

    func _init_all_state():
        state_list = [
            Init.InitState.new(self),
            Setup.SetupState.new(self),
            Turn.TurnState.new(self),
            GameOver.GameOverState.new(self),
        ]
        initial_state = state_list[0]
        activiate()