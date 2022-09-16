extends Node


# 状态机

class_name FSM


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
    func get_triggers() -> Array:
        return []


# 触发器
class Trigger:
    extends Reference

    var conditions: Array

    # 获得目标状态
    func get_target_state() -> State:
        return State.new()

    # 获得触发行动
    func get_actions() -> Array:
        return []

    # 是否触发
    func is_trigger() -> bool:
        var result = true
        for condition in conditions:
            result = result and condition.is_meet_condition()
        return result


# 条件
class Condition:
    extends Reference

    # 是否满足条件
    func is_meet_condition() -> bool:
        return false


# 一般状态机
class StateMachine:
    extends Reference

    var cur_state: State

    func _init(init_state):
        cur_state = init_state

    # 驱动状态机更新
    func update() -> Array:
        var triggered = null
        for trigger in cur_state.get_triggers():
            if trigger.is_trigger():
                triggered = trigger
        
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