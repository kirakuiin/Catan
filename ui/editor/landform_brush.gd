extends TextureButton


# 地形刷


export(Data.LandformType) var landform_type = Data.LandformType.NULL
var _callback: FuncRef = null


func _ready():
    texture_normal = load(UI_Data.LANDFORM_DATA[landform_type])


func set_callback(cb: FuncRef):
    _callback = cb


func activiate():
    _set_highlight(true)
    if _callback:
        _callback.call_func(landform_type)


func _on_button_toggled(is_pressed: bool):
    _set_highlight(is_pressed)
    if is_pressed and _callback:
        _callback.call_func(landform_type)


func _set_highlight(is_highlight: bool):
    material.set_shader_param("is_highlight", is_highlight)