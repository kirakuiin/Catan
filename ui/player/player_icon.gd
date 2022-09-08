extends Control


export(Color) var player_color: Color
export(int) var order_num: int


func _ready():
    $BgPanel/NumLabel.text = String(order_num)
    $BgPanel/NumLabel.add_color_override("font_color", player_color)


# 初始化头像
func init(player_info: Protocol.PlayerInfo):
    $Info.show()
    $Info/NameLabel.text = player_info.player_name
    $Info/NameLabel.add_color_override("font_color", player_color)
    $Info/AvatarTexture.texture = ResourceLoader.load(Data.ICON_DATA[player_info.icon_id])


# 清除头像
func clear():
    $Info.hide()