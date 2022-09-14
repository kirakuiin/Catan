extends Control

# 玩家信息编辑

var Avatar: PackedScene = preload("res://ui/info/player_avatar.tscn")


func _ready():
    randomize()
    _init_player_name()
    _init_avatar()
    _init_icon_grid_item()
    $Panel/VBoxContainer/IconContainer/PlayerAvatar.set_button_cb(funcref(self, "_on_change_icon"))


func _init_player_name():
    var name = PlayerConfig.get_player_name()
    $Panel/VBoxContainer/NameContainer/NameEdit.text = name


func _init_avatar():
    var icon = Data.ICON_DATA[PlayerConfig.get_icon_id()]
    $Panel/VBoxContainer/IconContainer/PlayerAvatar.set_icon(icon)


func _init_icon_grid_item():
    for id in Data.ICON_DATA:
        var button = Avatar.instance()
        button.set_icon(Data.ICON_DATA[id])
        button.set_button_cb(funcref(self, "_on_confirm_avatar"), id)
        $IconSelectScroll/IconSelectContainer.add_child(button)


func _on_confirm():
    SceneMgr.goto_scene(SceneMgr.MAIN_SCENE)


func _on_change_icon(id):
    $IconSelectScroll.show()


func _on_confirm_avatar(icon_id: int):
    $IconSelectScroll.hide()
    $Panel/VBoxContainer/IconContainer/PlayerAvatar.set_icon(Data.ICON_DATA[icon_id])
    PlayerConfig.save_icon_id(icon_id)


func _on_name_changed(new_text):
    PlayerConfig.save_player_name(new_text)
