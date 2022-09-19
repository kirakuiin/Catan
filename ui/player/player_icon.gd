extends Control


export(Color) var player_color: Color
export(int) var order_num: int


func _ready():
    $BgPanel/NumLabel.text = String(order_num)
    $BgPanel/NumLabel.add_color_override("font_color", player_color)
    $Info/BorderTexture.rect_pivot_offset = $Info/BorderTexture.rect_size/2


# 初始化头像
func init(player_info: Protocol.PlayerInfo):
    $Info.show()
    $Info/NameLabel.text = player_info.player_name
    $Info/NameLabel.add_color_override("font_color", player_color)
    $Info/AvatarTexture.texture = ResourceLoader.load(Data.ICON_DATA[player_info.icon_id])


# 清除头像
func clear():
    $Info.hide()


# 设置处于玩家回合
func set_on_turn(is_your_turn):
    if is_your_turn:
        $AnimationPlayer.play("rotate")
    else:
        $AnimationPlayer.play("RESET")