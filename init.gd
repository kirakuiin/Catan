extends Node

# 初始化

const DebugPopup = preload("res://ui/info/debug_popup.tscn")


var _is_open_debug: bool=false


func _ready():
    Log.logi("游戏开始初始化.")
    _init_game_setting()
    _init_log_setting()
    _init_audio_setting()
    Log.logi("游戏初始化完毕.")


func _init_log_setting():
    #Log.get_logger(Log.LogModule.SERVER).disable()
    #Log.get_logger(Log.LogModule.CLIENT).disable()
    #Log.get_logger(Log.LogModule.SCENE).disable()
    #Log.get_logger(Log.LogModule.CONN).disable()
    pass


func _init_game_setting():
    randomize()
    MapLoader.create_map_dir()


func _init_audio_setting():
    Audio.play_bg()


func _input(event):
    if Input.is_action_just_pressed("open_debug") and not _is_open_debug:
        _is_open_debug = true
        var popup = DebugPopup.instance()
        get_tree().get_root().add_child(popup)
        popup.connect("popup_hide", self, "_on_debug_close")
        popup.popup_centered()


func _on_debug_close():
    _is_open_debug = false