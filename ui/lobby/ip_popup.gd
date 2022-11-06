extends PopupDialog

# ip直连窗口

const ConnPopup: PackedScene = preload("res://ui/lobby/connecting.tscn")


func _on_confirm():
    var ip = $LineEdit.text
    if ip.is_valid_ip_address():
        var conn = ConnPopup.instance()
        conn.popup_with_target(ip)
        GameServer.join_game(ip)
        hide()
    else:
        SceneMgr.show_prompt("ip地址无效!")


func _on_cancel():
    hide()


func hide():
    .hide()
    $LineEdit.text = ""