extends PopupDialog


# 调试面板

func _ready():
    $Scroll/Grid/RandomName/Btn.pressed = PlayerConfig.is_random_name()


func _on_random_name_toggled(is_pressed: bool):
    PlayerConfig.save_random_name(is_pressed)


func _on_popup_hide():
    queue_free()
