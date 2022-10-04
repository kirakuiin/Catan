extends Node

# 通用功能

class_name Util


# 整数范围随机[from, to)
static func randi_range(from: int, to: int):
    return randi() % (to-from) + from


# 以中心为坐标设置对象位置
static func set_center(obj: Control, pos: Vector2):
    var size = obj.rect_size
    obj.rect_position = Vector2(pos.x-size.x/2, pos.y-size.y/2)


# 获得项目屏幕尺寸
static func get_windows_size() -> Vector2:
    return Vector2(ProjectSettings.get_setting("display/window/size/width"),
                        ProjectSettings.get_setting("display/window/size/height"))


# 颜色转字符串
static func color_to_str(color: Color):
    var colors = PoolByteArray([color.a8, color.r8, color.g8, color.b8])
    return "#"+colors.hex_encode()


# 音量转为db
static func volume_to_db(volume: int) -> float:
    if volume <= 0:
        return ProjectSettings.get_setting("audio/channel_disable_threshold_db")-1
    else:
        return 10*log(volume/100.0)/log(10)


# 秒转时间字符串
static func time_convert(time_in_sec: int, fmt: String="%02d时:%02d分:%02d秒") -> String:
    var seconds = time_in_sec%60
    var minutes = (time_in_sec/60)%60
    var hours = (time_in_sec/60)/60
    return fmt % [hours, minutes, seconds]
