extends Control


# 玩家信息属性项

export(Texture) var icon


var _format: String = "%s"


func _ready():
    $HBox/Icon.texture = icon


func set_text(text: String):
    $HBox/Text.text = _format % text


func set_format(format: String):
    _format = format
    set_text($HBox/Text.text)


func set_highlight(is_highlight: bool):
    if is_highlight:
        $AnimationPlayer.play("highlight")
    else:
        $AnimationPlayer.play("RESET")