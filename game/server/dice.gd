extends Reference


# 骰子模拟

var _dice_1 :RandomNumberGenerator
var _dice_2 :RandomNumberGenerator
var _last_result: Array


func _init():
    _dice_1 = RandomNumberGenerator.new()
    _dice_1.randomize()
    _dice_2 = RandomNumberGenerator.new()
    _dice_2.randomize()


# 投掷两个d6
func roll() -> Array:
    _last_result = [_dice_1.randi_range(1, 6), _dice_2.randi_range(1, 6)]
    return _last_result
    

# 返回上次投掷的结果
func get_last_num() -> int:
    return _last_result[0] + _last_result[1]