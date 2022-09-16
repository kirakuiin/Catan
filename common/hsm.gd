extends Node


# 分层状态机

class_name HSM



# 存储更新结果
class UpdateResult:
    extends Reference

    var level: int
    var actions: Array
    var transition: Transition

    func _init(lv: int=0, acs: Array=[], ts=null):
        level = lv
        actions = acs
        transition = ts


class HSMBase:
    extends Reference

    # 返回所有的行动
    func get_actions() -> Array:
        return []

    # 返回状态机更新后的结果
    func update() -> UpdateResult:
        var result = UpdateResult.new(0, get_actions(), null)
        return result

    # 返回当前的状态机层次
    func get_states() -> Array:
        return []


# 状态
class State:
    extends HSMBase

    func _to_string():
        return 'HSState'
    
    func get_states() -> Array:
        return [self]

    # 返回父状态机
    func get_parent_machine():
        return null

    # 得到所有行动
    func get_actions() -> Array:
        return []

    # 获得进入此状态该执行的行动
    func get_entry_actions() -> Array:
        return []

    # 获得退出此状态该执行的行动
    func get_exit_actions() -> Array:
        return []

    # 获得所有的触发器
    func get_transitions() -> Array:
        return []


# 转换
class Transition:
    extends HSMBase

    var target_state: State
    var actions: Array
    var conditions: Array
    var level: int
    
    func _init(target: State, lv: int, ac_list: Array=[], conds: Array=[]):
        target_state = target
        level = lv
        actions = ac_list
        conditions = conds

    # 返回转换的层级
    # 0: 平级, n: 目标高于来源n级, -n: 目标低于来源n级
    func get_level():
        return level

    # 获得目标状态
    func get_target_state() -> State:
        return target_state

    # 获得触发行动
    func get_actions() -> Array:
        return actions

    # 是否触发
    func is_triggered() -> bool:
        var result = true
        for condition in conditions:
            result = result and condition.is_meet_condition()
        return result


# 混合状态状态机
class SubMachineState:
    extends State

    var machine: StateMachine

    func _to_string():
        return "SubMachine"

    func update() -> UpdateResult:
        return machine.update()

    func get_states() -> Array:
        var states := [self]
        return states + machine.get_states()
        
    func update_down(level: int, state: State) -> Array:
        return machine.update_down(level, state)

    func set_cur_state(state: State):
        machine.set_cur_state(state)
        
    func get_cur_state() -> State:
        return machine.get_cur_state()


# 分层状态机
class StateMachine:
    extends HSMBase

    var _initial_state: State
    var _cur_state: State
    var _parent

    func _init(ini_state: State, parent=null):
        _initial_state = ini_state
        _parent = parent

    func _to_string():
        return "HSMachine"

    func get_states() -> Array:
        if get_cur_state():
            return get_cur_state().get_states()
        else:
            return []

    # 返回当前状态
    func get_cur_state() -> State:
        return _cur_state

    # 设置当前状态
    func set_cur_state(state: State):
        _cur_state = state

    func update() -> UpdateResult:
        var result = UpdateResult.new()
        if not get_cur_state():
            set_cur_state(_initial_state)
            result = UpdateResult.new(0, get_cur_state().get_entry_actions())
        else:
            result = _get_transition_result(_find_transition())
            _expand_actions(result)
        return result

    func _find_transition() -> Transition:
        for transition in get_cur_state().get_transitions():
            if transition.is_triggered():
                return transition
        return null

    func _get_transition_result(transition: Transition) -> UpdateResult:
        if transition:
            return UpdateResult.new(transition.get_level(), [], transition)
        else:
            return get_cur_state().update()

    func _expand_actions(result: UpdateResult):
        if result.transition:
            if result.level == 0:
                _expand_same_level(result)
            elif result.level > 0:
                _expand_high_level(result)
            else:
                _expand_low_level(result)
        else:
            result.actions += get_actions()

    func _expand_same_level(result: UpdateResult):
        var target_state = result.transition.get_target_state()
        result.actions += get_cur_state().get_exit_actions()
        result.actions += result.transition.get_actions()
        result.actions += target_state.get_entry_actions()
        set_cur_state(target_state)
        result.actions += get_actions()
        result.transition = null

    func _expand_high_level(result: UpdateResult):
        result.actions += get_cur_state().get_exit_actions()
        set_cur_state(null)
        result.level -= 1

    func _expand_low_level(result: UpdateResult):
        var target_state = result.transition.get_target_state()
        var target_machine = target_state.get_parent_machine()
        result.actions += result.transition.get_actions()
        result.actions += target_machine.update_down(abs(result.transition.level), target_state)
        result.transition = null

    func update_down(level: int, state: State) -> Array:
        var actions := []
        if level > 0:
            actions = _parent.update_down(level-1, self)
        if get_cur_state():
            actions += get_cur_state().get_exit_actions()
        set_cur_state(state)
        actions += state.get_entry_actions()
        return actions


# 动作
class Action:
    extends Reference

    var callback: FuncRef
    var params: Array

    func _init(cb: FuncRef, param_list: Array):
        callback = cb
        params = param_list

    # 执行动作
    func invoke():
        callback.call_funcv(params)


# 条件
class Condition:
    extends Reference

    # 是否满足条件
    func is_meet_condition() -> bool:
        return false