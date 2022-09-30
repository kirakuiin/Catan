extends PopupDialog


# 银行交易弹窗


func _on_cancel():
    queue_free()


func _on_confirm():
    queue_free()
