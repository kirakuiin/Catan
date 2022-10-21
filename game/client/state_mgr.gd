extends Reference


# 客户端运行状态管理器

const SAVE_PATH: String = "user://[%s]_runtime.ini"
const RUNTIME_SECTION: String = "Runtime"

var _config := ConfigFile.new()
var _file_path: String


func _init(player_name: String):
    _file_path = SAVE_PATH % player_name
    _config.load(_file_path)


# 存储客户端状态
func save_client_state(state: String, params: Dictionary):
    _config.set_value(RUNTIME_SECTION, "client_state", state)
    _config.set_value(RUNTIME_SECTION, "state_params", var2str(params))
    _config.save(_file_path)


# 读取客户端状态
func get_client_state() -> String:
    return _config.get_value(RUNTIME_SECTION, "client_state", NetDefines.ClientState.IDLE)


# 读取客户端状态参数
func get_state_params() -> Dictionary:
    return str2var(_config.get_value(RUNTIME_SECTION, "state_params", '"{}"'))