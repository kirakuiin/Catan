extends Control


# 资源选择按钮


export(Data.ResourceType) var res_type: int

var _callback: FuncRef = null
var _num = 0


func _ready():
    $Btn.texture_normal = load(UI_Data.RES_ICON_DATA[res_type])


# 设置回调
func set_callback(cb: FuncRef):
    _callback = cb


# 设置选择数量
func select():
    _num += 1
    $Selected.show()
    if _num > 1:
        $Num.text = str(_num)
    _update_num()


# 取消选择
func unselect():
    _num -= 1
    if _num == 0:
        $Selected.hide()
    _update_num()


func _update_num():
    $Num.text = str(_num)
    if _num > 1:
        $Num.show()
    else:
        $Num.hide()


# 返回资源类型
func get_type() -> int:
    return res_type


func _on_select():
    if _callback:
        _callback.call_func(self)