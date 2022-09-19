extends Control


# 玩家信息属性项

export(Texture) var icon


var _format: String = "%s"


func _ready():
    $HBox/Icon.texture = icon


func set_num(num: int):
    $HBox/Text.text = _format % num


func set_format(format: String):
    _format = format
    set_num(int($HBox/Text.text))


func set_highlight(is_highlight: bool):
    if is_highlight:
        $AnimationPlayer.play("highlight")
    else:
        $AnimationPlayer.play("RESET")