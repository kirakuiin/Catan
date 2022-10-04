extends Reference


# 客户端配置

signal client_setting_changed(setting)  # 客户端配置变化


var is_auto_pass: bool = false setget set_auto_pass


# 设置自动让过
func set_auto_pass(is_auto: bool):
    is_auto_pass = is_auto
    emit_signal("client_setting_changed", self)