extends Control

# 交易单项


export(Data.ResourceType) var res_type: int

var unit: int = 4
var _num: int

func _ready():
    $Texture.texture = load(Data.RES_ICON_DATA[res_type])
    set_num(4)


# 设置基础数值
func set_num(num: int):
    _num = num
    $Num.text = str(_num)


func _on_get():
    if _pay_num() > 0:
        _sub_pay()
    else:
        _plus_get()

func _pay_num() -> int:
    return int($Pay.text)

func _sub_pay():
    var val = _pay_num()
    $Pay.text = str(val-unit)
    _num += unit
    $Num.text = str(_num)

func _plus_get():
    var val = _get_num()
    $Get.text = str(val+1)
    _num += 1
    $Num.text = str(_num)

func _get_num() -> int:
    return int($Get.text)


func _on_pay():
    if _get_num() > 0:
        _sub_get()
    else:
        _plus_pay()

func _sub_get():
    var val = _get_num()
    $Get.text = str(val-1)
    _num -= 1
    $Num.text = str(_num)

func _plus_pay():
    var val = _pay_num()
    if _num-unit >= 0:
        $Pay.text = str(val+unit)
        _num -= unit
        $Num.text = str(_num)