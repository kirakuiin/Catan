extends Control

# 骰子

const DICE_ONE_FRAME = [0, 1, 4, 5, 8, 9]
const DICE_TWO_FRAME = [2, 3, 6, 7, 10, 11]


var _dice_value: Array = [1, 1]
var _origin_one_pos: Vector2
var _origin_two_pos: Vector2


func random_frame():
    $DiceOne.frame = DICE_ONE_FRAME[Util.randi_range(0, 6)]
    $DiceTwo.frame = DICE_TWO_FRAME[Util.randi_range(0, 6)]


func final_frame():
    $DiceOne.frame = DICE_ONE_FRAME[_dice_value[0]-1]
    $DiceTwo.frame = DICE_TWO_FRAME[_dice_value[1]-1]


func move_to_center():
    $DiceOne.position = $CenterOne.rect_position+$CenterOne.rect_size/2
    $DiceTwo.position = $CenterTwo.rect_position+$CenterTwo.rect_size/2


func move_to_origin():
    $DiceOne.position = $LocationOne.rect_position+$LocationOne.rect_size/2
    $DiceTwo.position = $LocationTwo.rect_position+$LocationTwo.rect_size/2


func init():
    _init_signal()
    move_to_origin()


func _init_signal():
    _get_client().connect("dice_changed", self, "_on_dice_changed")


func _get_client():
    return PlayingNet.get_client()


func _on_dice_changed(info: Array):
    _dice_value = info
    $AnimationPlayer.play("roll")