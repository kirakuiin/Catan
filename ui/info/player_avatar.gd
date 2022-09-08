extends Control

# 玩家头像

var _callback: FuncRef = null
var _params = null


func set_icon(icon_path: String):
    $PlayerBg/TextureButton.texture_normal = ResourceLoader.load(icon_path)


func set_button_cb(callback: FuncRef, params=null):
    _callback = callback
    _params = params


func _on_button_down():
    if _callback and _callback.is_valid():
        _callback.call_func(_params)
