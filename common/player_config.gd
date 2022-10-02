extends Node

# 玩家配置

const CONFIG_PATH: String = "user://player_config.ini"
const PLAYER_SECTION: String = "Player"


var _config = ConfigFile.new()
onready var _name = str(rand_range(10000, 20000) as int)  # 测试使用


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
    # return _name
    return _config.get_value(PLAYER_SECTION, "player_name", str(rand_range(10000, 20000) as int))


func get_icon_id() -> int:
    return _config.get_value(PLAYER_SECTION, "player_avatar", 1)
