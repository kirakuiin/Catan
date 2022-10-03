extends Control

# 主机列表项

export(Color) var highlight_color
export(Color) var origin_color


func _on_ready():
    no_highlight()


func set_host_name(name: String) -> void:
    $InfoContainer/HostNameLabel.text = name


func set_ip(ip: String) -> void:
    $InfoContainer/IPLabel.text = ip


func set_num(cur_num: int, max_num: int) -> void:
    $InfoContainer/NumLabel.text = "[%s/%s]" % [cur_num, max_num]


func set_state(state: int) -> void:
    if state == Data.HostState.PLAYING:
        $InfoContainer/StateLabel.text = '游戏中'
        $InfoContainer/StateLabel.modulate = Color.red
    elif state == Data.HostState.PREPARE:
        $InfoContainer/StateLabel.text = '准备中'
        $InfoContainer/StateLabel.modulate = Color.green


func set_group(group: ButtonGroup):
    $SelectBtn.group = group


func set_join_signal(target):
    target.connect("joined_game", self, "_on_join_game")


func get_ip():
    return $IPLabel.text


func highlight():
    $InfoContainer/HostNameLabel.add_color_override("font_color", highlight_color)


func no_highlight():
    $InfoContainer/HostNameLabel.add_color_override("font_color", origin_color)


func _on_join_game():
    if $SelectBtn.pressed:
        GameServer.join_game($InfoContainer/IPLabel.text)


func _on_select(button_pressed: bool):
    if button_pressed:
        highlight()
    else:
        no_highlight()

