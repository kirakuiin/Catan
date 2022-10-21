extends Node

# 布置面板阶段

const Turn: Script = preload("res://game/server/state/turn_state.gd")
const Condition: Script = preload("res://game/server/state/conditions.gd")
const Action: Script = preload("res://game/server/state/actions.gd")


# 玩家初始化
class SetupState:
    extends HSM.SubMachineState

    func _init(parent).(parent):
        _machine = HSM.StateMachine.new(parent)
        _init_all_state()
    
    func _to_string():
        return 'SetupState'

    func _init_all_state():
        for name in get_name_list():
            _append_state(name, false)
        for name in get_name_list(true):
            _append_state(name, true)
        _machine.state_list.append(EndState.new(self))
        _machine.initial_state = _machine.state_list[0]

    func get_name_list(is_reverse: bool=false) -> Array:
        var orders = PlayingNet.get_server().order_info.order_to_name.keys()
        orders.sort()
        if is_reverse:
            orders.invert()
        var result = []
        for order in orders:
            result.append(PlayingNet.get_server().order_info.order_to_name[order])
        return result

    func _append_state(name: String, is_last):
        _machine.state_list.append(PlaceSettlementState.new(self, name, is_last))
        _machine.state_list.append(PlaceRoadState.new(self, name))


# 放置定居点
class PlaceSettlementState:
    extends HSM.State
    
    var _name: String
    var _is_last: bool

    func _init(parent, name: String, is_last_turn: bool).(parent):
        _name = name
        _is_last = is_last_turn

    func _to_string():
        return "PlaceSettlementState[%s]" % _name

    func activiate():
        _init_transitions()
        _init_actions()

    func _init_transitions():
        var state_list = get_parent_machine().get_state_list() as Array
        var index = state_list.find(self)
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(state_list[index+1], 0, condition))

    func _init_actions():
        _entry_actions.append(Action.notify_place_settlement(_name, NetDefines.SettlementType.SETUP))
        _entry_actions.append(Action.set_turn_name(_name))
        if _is_last:
            _exit_actions.append(Action.initial_res(_name))


# 放置定居点
class PlaceRoadState:
    extends HSM.State

    var _name: String

    func _init(parent, name: String).(parent):
        _name = name
        
    func _to_string():
        return "PlaceRoadState[%s]" % _name

    func activiate():
        _init_transitions()
        _init_actions()

    func _init_transitions():
        var state_list = get_parent_machine().get_state_list() as Array
        var index = state_list.find(self)
        var condition = Condition.PlayerStateCondition.new(_name, NetDefines.PlayerNetState.DONE)
        add_transition(HSM.Transition.new(state_list[index+1], 0, condition))

    func _init_actions():
        _entry_actions.append(Action.notify_place_road(_name, NetDefines.RoadType.SETUP))


# 结束
class EndState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "EndState"

    func activiate():
        var turn_state = get_state_in_parent(Turn.TurnState)
        add_transition(HSM.Transition.new(turn_state, 1, HSM.TrueCondition.new()))
        for name in get_parent_machine().get_name_list():
            _exit_actions.append(Action.reset_net_state(name))

