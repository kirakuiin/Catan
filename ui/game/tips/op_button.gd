extends TextureButton

# 操作按钮

const Tips: PackedScene = preload("res://ui/game/tips/required_tips.tscn")

export(Data.OpType) var btn_type: int

var _tips = null


func _ready():
    texture_normal = ResourceLoader.load(UI_Data.OP_BTN_DATA[btn_type])
    texture_disabled = ResourceLoader.load(UI_Data.OP_DISABLE_DATA[btn_type])
    connect("mouse_entered", self, "_on_mouse_entered")
    connect("mouse_exited", self, "_on_mouse_exited")


func _on_mouse_entered():
    _tips = _create_tips()
    add_child(_tips)
    _tips.rect_position = -Vector2(_tips.rect_size.x/2, _tips.rect_size.y)


func _on_mouse_exited():
    _tips.queue_free()


func _create_tips() -> Control:
    var tips = Tips.instance()
    tips.set_title(_get_title())
    tips.set_res(_get_resource())
    return tips


func _get_title() -> String:
    var title = ""
    match btn_type:
        Data.OpType.SETTLEMENT:
            title = "放置定居点"
        Data.OpType.ROAD:
            title = "放置道路"
        Data.OpType.CITY:
            title = "升级城市"
        Data.OpType.DEV_CARD:
            title = "购买发展卡"
    return title


func _get_resource() -> String:
    var message = Message.RichMessage.new()
    for res_type in Data.OP_DATA[btn_type]:
        message.add_resource(res_type)
        message.add_text("[%d] " % Data.OP_DATA[btn_type][res_type])
    return message.bbcode()
