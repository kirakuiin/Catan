extends Node

# 游戏配置

const CONFIG_PATH: String = "user://player_config.ini"
const PLAYER_SECTION: String = "Player"
const DEBUG_SECTION: String = "Debug"
const GAME_SECTION: String = "Game"


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
    if is_random_name():
        return _rand_name
    else:
        return _config.get_value(PLAYER_SECTION, "player_name", _rand_name)


func get_icon_id() -> int:
    return _config.get_value(PLAYER_SECTION, "player_avatar", 1)


func is_random_name() -> bool:
    return _config.get_value(DEBUG_SECTION, "random_name", false)


func save_random_name(is_random: bool):
    _config.set_value(DEBUG_SECTION, "random_name", is_random)
    _config.save(CONFIG_PATH)


func get_master_volume() -> int:
    return _config.get_value(GAME_SECTION, "master_volume", 50)


func set_master_volume(volume: int):
    _config.set_value(GAME_SECTION, "master_volume", volume)
    _config.save(CONFIG_PATH)


func get_bg_volume() -> int:
    return _config.get_value(GAME_SECTION, "bg_volume", 100)


func set_bg_volume(volume: int):
    _config.set_value(GAME_SECTION, "bg_volume", volume)
    _config.save(CONFIG_PATH)


func get_effect_volume() -> int:
    return _config.get_value(GAME_SECTION, "effect_volume", 100)


func set_effect_volume(volume: int):
    _config.set_value(GAME_SECTION, "effect_volume", volume)
    _config.save(CONFIG_PATH)