extends Node

# 玩家配置

const CONFIG_PATH: String = "user://player_config.ini"
const PLAYER_SECTION: String = "Player"
const DEBUG_SECTION: String = "Debug"


var _config = ConfigFile.new()
onready var _rand_name = str(rand_range(10000, 20000) as int)  # 随机生成名


func _init():
    randomize()
    _config.load(CONFIG_PATH)


func save_player_name(name: String):
    _config.set_value(PLAYER_SECTION, "player_name", name)
    _config.save(CONFIG_PATH)


func save_icon_id(icon_id: int):
    _config.set_value(PLAYER_SECTION, "player_avatar", icon_id)
    _config.save(CONFIG_PATH)


func get_player_name() -> String:
    if _is_random_name():
        return _rand_name
    else:
        return _config.get_value(PLAYER_SECTION, "player_name", _rand_name)


func get_icon_id() -> int:
    return _config.get_value(PLAYER_SECTION, "player_avatar", 1)


func _is_random_name() -> bool:
    return _config.get_value(DEBUG_SECTION, "random_name", false)