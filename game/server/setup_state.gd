extends Node

# 布置面板阶段


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
            _append_state(name)
        for name in get_name_list(true):
            _append_state(name)
        _machine.state_list.append(EndState.new(self))
        _machine.initial_state = _machine.state_list[0]

    func get_name_list(is_reverse: bool=false) -> Array:
        var orders = get_root().get_server().order_info.order_to_name.keys()
        orders.sort()
        if is_reverse:
            orders = orders.slice(len(orders)-1, 0, -1)
        var result = []
        for order in orders:
            result.append(get_root().get_server().order_info.order_to_name[order])
        return result

    func _append_state(name: String):
        _machine.state_list.append(PlaceSettlementState.new(self, name))
        _machine.state_list.append(PlaceRoadState.new(self, name))


# 放置定居点
class PlaceSettlementState:
    extends HSM.State
    
    var _name: String

    func _init(parent, name: String).(parent):
        _name = name

    func _to_string():
        return "PlaceSettlementState[%s]" % _name

    func activiate():
        _init_transitions()
        _init_actions()

    func _init_transitions():
        var state_list = get_parent_machine().get_state_list() as Array
        var index = state_list.find(self)
        var conditions = [PlaceDoneCondition.new(
            _name, get_root().get_server().player_state, NetDefines.PlayerOpState.PLACE_SETTLEMENT_DONE)]
        add_transition(HSM.Transition.new(state_list[index+1], 0, conditions))

    func _init_actions():
        _entry_actions.append(HSM.Action.new(funcref(get_root().get_server(), "notify_place_settlement"), [_name]))


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
        var conditions = [PlaceDoneCondition.new(
            _name, get_root().get_server().player_state, NetDefines.PlayerOpState.PLACE_ROAD_DONE)]
        add_transition(HSM.Transition.new(state_list[index+1], 0, conditions))

    func _init_actions():
        _entry_actions.append(HSM.Action.new(funcref(get_root().get_server(), "notify_place_road"), [_name]))


# 结束
class EndState:
    extends HSM.State

    func _init(parent).(parent):
        pass

    func _to_string():
        return "EndState"


class PlaceDoneCondition:
    extends HSM.Condition

    var _name: String
    var _player_state: Dictionary
    var _done_type: int

    func _init(name: String, states: Dictionary, done_type: int):
        _name = name
        _player_state = states
        _done_type = done_type
        
    func is_meet_condition() -> bool:
        return _player_state[_name] == _done_type