extends Node


# 日志模块

enum LogLevel {
    INFO=1,
    DEBUG=2,
    WARNING=3,
    ERROR=4,
}

const LOG_PATH: String = "user://%s_catan[%s].log"

class LogModule:
    extends Reference

    const DEFAULT: String = "game"
    const COMMON: String = "common"
    const SCENE: String = "scene"
    const CLIENT: String = "client"
    const SERVER: String = "server"
    const CONN: String = "conn"
    const TRADE: String = "trade"
    const AUDIO: String = "audio"


var _logger_info: Dictionary
var _file: File


func _ready():
    _file = File.new()
    _file.open(LOG_PATH % [GameConfig.get_player_name(), Time.get_date_string_from_system()], File.WRITE)
    _logger_info = {LogModule.DEFAULT: Logger.new(_file, LogModule.DEFAULT)}


# 返回指定模块的日志记录器
func get_logger(type: String) -> Logger:
    if not type in _logger_info:
        _logger_info[type] = Logger.new(_file, type)
    return _logger_info[type]


# 打印信息
func logi(msg):
    get_logger(LogModule.DEFAULT).logi(msg)


# 打印调试
func logd(msg):
    get_logger(LogModule.DEFAULT).logd(msg)


# 打印警告
func logw(msg):
    get_logger(LogModule.DEFAULT).logw(msg)


# 打印错误
func loge(msg):
    get_logger(LogModule.DEFAULT).loge(msg)


# 日志记录器
class Logger:
    extends Reference

    var log_level: int = LogLevel.INFO
    var is_stdout: bool = true
    var is_save_file: bool = true
    var is_show_time: bool = false
    var is_show_track: bool = false
    var is_enable: bool = true

    var _file: File
    var _type: String

    func _init(file_handle: File, type: String):
        _file = file_handle
        _type = type

    # 设置日志
    func setting(settings: Dictionary):
        log_level = settings.get("log_level", LogLevel.INFO)
        is_stdout = settings.get("enable_stdout", true)
        is_save_file = settings.get("enable_save_file", true)
        is_show_time = settings.get("is_show_time", false)
        is_show_track = settings.get("is_show_track", false)

    # 启动
    func enable():
        is_enable = true

    # 关闭
    func disable():
        is_enable = false

    # 打印信息
    func logi(msg):
        if log_level <= LogLevel.INFO:
            _output_msg("INFO", msg)

    # 打印调试
    func logd(msg):
        if log_level <= LogLevel.DEBUG:
            _output_msg("DEBUG", msg)

    # 打印警告
    func logw(msg):
        if log_level <= LogLevel.DEBUG:
            _output_msg("WARNING", msg)

    # 打印错误
    func loge(msg):
        if log_level <= LogLevel.DEBUG:
            _output_msg("ERROR", msg)

    func _output_msg(head, msg):
        if not is_enable:
            return
        var fmt_msg = _get_fmt_msg(head, msg)
        if is_stdout:
            print(fmt_msg)
        if is_save_file:
            _save_file(fmt_msg)

    func _get_fmt_msg(head, msg) -> String:
        var result: String = ""
        var time = Time.get_datetime_string_from_system(false, true) if is_show_time else ""
        var track = String(get_stack()[2]) if is_show_track else ""
        if is_show_time and is_show_track:
            result = "[%s] [%s]%s |[%s]|[%s]|" % [head, _type, msg, time, track]
        elif not (is_show_time or is_show_track):
            result = "[%s] [%s]%s" % [head, _type, msg]
        else:
            result = "[%s] [%s]%s |[%s]" % [head, _type, msg, time if time else track]
        return result

    func _save_file(msg):
        _file.store_string(msg+"\n")
        _file.flush()

