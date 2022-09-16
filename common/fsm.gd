extends Node


# 有限状态机



# 状态类
class State:
    extends Reference

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


# 转换
class Transition:
    extends Reference

    var target_state: State
    var actions: Array
    var conditions: Array
    
    func _init(target:State, ac_list: Array=[], conds: Array=[]):
        target_state = target
        actions = ac_list
        conditions = conds

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


# 有限状态机
class StateMachine:
    extends Reference

    var cur_state: State

    func _init(init_state):
        cur_state = init_state

    # 驱动状态机更新
    func update() -> Array:
        var triggered = null
        for trigger in cur_state.get_transitions():
            if trigger.is_triggered():
                triggered = trigger
                break
        
        var actions = []
        if triggered:
            var tar_state = triggered.get_target_state()
            actions.append_array(cur_state.get_exit_actions())
            actions.append(triggered.get_actions())
            actions.append(tar_state.get_entry_actions())
            cur_state = tar_state
        else:
            actions.append_array(cur_state.get_actions())
        return actions

