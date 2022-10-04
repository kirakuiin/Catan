extends PopupDialog


# 调试面板

func _ready():
    $Scroll/Grid/RandomName/Btn.pressed = GameConfig.is_random_name()


func _on_random_name_toggled(is_pressed: bool):
    GameConfig.save_random_name(is_pressed)


func _on_popup_hide():
    queue_free()
