extends Node


# 日志模块

enum LogLevel {
    INFO=1,
    DEBUG=2,
    WARNING=3,
    ERROR=4,
}


const LOG_PATH: String = "user://%s_catan.log"


var log_level: int = LogLevel.INFO
var is_stdout: bool = true
var is_save_file: bool = false
var is_show_time: bool = false
var is_show_track: bool = false

var _file: File


func _ready():
    if is_save_file:
        _file = File.new()
        _file.open(LOG_PATH % PlayerConfig.get_player_name(), File.WRITE)


# 设置日志
func setting(settings: Dictionary):
    log_level = settings.get("log_level", LogLevel.INFO)
    is_stdout = settings.get("enable_stdout", true)
    is_save_file = settings.get("enable_save_file", true)
    is_show_time = settings.get("is_show_time", false)
    is_show_track = settings.get("is_show_track", false)


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
        result = "[%s] %s |[%s]|[%s]|" % [head, msg, time, track]
    elif not (is_show_time or is_show_track):
        result = "[%s] %s" % [head, msg]
    else:
        result = "[%s] %s |[%s]" % [head, msg, time if time else track]
    return result


func _save_file(msg):
    _file.store_string(msg)
    _file.flush()