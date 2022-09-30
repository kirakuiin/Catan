extends AcceptDialog

# 提示

func set_msg(text: String):
    dialog_text = text


func _on_confirm():
    queue_free()
