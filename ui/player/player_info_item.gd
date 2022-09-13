extends Control


# 玩家信息属性项

export(Texture) var icon


func _ready():
    $HBox/Icon.texture = icon


func set_text(text: String):
    $HBox/Text.text = text