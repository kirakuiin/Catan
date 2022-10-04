extends Control


const AutoPassActiviate = preload("res://assets/images/pass_turn.png")
const AutoPassInactiviate = preload("res://assets/images/pass_turn_disable.png")


# 初始化
func init():
    pass


func _on_switch_auto_pass(is_pressed: bool):
    if is_pressed:
        $Grid/AutoPass.texture_normal = AutoPassActiviate
    else:
        $Grid/AutoPass.texture_normal = AutoPassInactiviate
    _get_client().setting_mgr.set_auto_pass(is_pressed)


func _get_client():
    return PlayingNet.get_client()