extends PopupDialog


# 地图保存弹窗


signal map_saved(map_name)


func _on_confirm():
    emit_signal("map_saved", $LineEdit.text)
    clear()
    hide()


func _on_cancel():
    hide()
    clear()


func clear():
    $LineEdit.text = ""