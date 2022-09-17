extends Node


# 服务端状态


const Init: Script = preload("res://game/server/init_state.gd")
const Setup: Script = preload("res://game/server/setup_state.gd")


# 服务端状态机
class CatanStateMachine:
    extends HSM.StateMachine 

    var _server_ref: WeakRef

    func _init(server).(null):
        _server_ref = weakref(server)
        _init_all_state()
        Log.logd("当前状态: %s" % String(get_states()))

    func _init_all_state():
        initial_state = Init.InitState.new(self)
        state_list = [initial_state, Setup.SetupState.new(self)]
        activiate()

    func get_server():
        return _server_ref.get_ref()