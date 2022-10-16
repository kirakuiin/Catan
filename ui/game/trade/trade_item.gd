extends Control

# 交易单项


signal trade_changed(res_type, num, unit)  # 交易需求变化


export(Data.ResourceType) var res_type: int
export(bool) var enable_unit: bool 
export(bool) var check_valid: bool


var _unit: int = 1
var _origin: int
var _num: int


func _ready():
    $Texture.texture = load(UI_Data.RES_ICON_DATA[res_type])
    set_num(StdLib.dict_get(_get_client().player_cards[_get_name()].res_cards, res_type, 0))
    set_activiate(false)
    if enable_unit:
        _init_unit()


# 设置基础数值
func set_num(num: int):
    _origin = num
    _num = num
    $Num.text = str(_num)


# 设置激活状态
func set_activiate(is_activiate: bool):
    if is_activiate:
        self.modulate.a = 1
    else:
        self.modulate.a = 0.3
    

# 设置初始面板
func set_item(trade_info: Protocol.TradeInfo):
    _reset()
    for type in trade_info.get_info:
        if res_type == type:
            for i in abs(trade_info.get_info[type]):
                _plus_get()
    for type in trade_info.pay_info:
        if res_type == type:
            for i in abs(trade_info.pay_info[type]):
                _plus_pay()

func _reset():
    set_num(_origin)
    $Get.text = "0"
    $Pay.text = "0"


# 初始化单位
func _init_unit():
    var types = _get_client().build_mgr.get_all_harbor_type()
    _unit = 4
    if types.contains(Data.HarborType.GENERIC):
        _unit = Data.HARBOR_UNIT[Data.HarborType.GENERIC]
    if types.contains(Data.RES_TO_HARBOR[res_type]):
        _unit = Data.HARBOR_UNIT[Data.RES_TO_HARBOR[res_type]]


func _on_get():
    if _pay_num() > 0:
        _sub_pay()
    else:
        _plus_get()
    _emit()

func _pay_num() -> int:
    return int($Pay.text)

func _sub_pay():
    var val = _pay_num()
    $Pay.text = str(val-_unit)
    _num += _unit
    $Num.text = str(_num)
    _switch_activiate()

func _plus_get():
    var val = _get_num()
    if val >= _get_client().bank_info.res_info[res_type] and check_valid:
        return
    $Get.text = str(val+1)
    _num += 1
    $Num.text = str(_num)
    _switch_activiate()

func _get_num() -> int:
    return int($Get.text)


func _on_pay():
    if _get_num() > 0:
        _sub_get()
    else:
        _plus_pay()
    _emit()

func _sub_get():
    var val = _get_num()
    $Get.text = str(val-1)
    _num -= 1
    $Num.text = str(_num)
    _switch_activiate()

func _plus_pay():
    if _num-_unit < 0 and check_valid:
        return
    $Pay.text = str(_pay_num()+_unit)
    _num -= _unit
    $Num.text = str(_num)
    _switch_activiate()

func _switch_activiate():
    if _num != _origin:
        set_activiate(true)
    else:
        set_activiate(false)

func _emit():
    var want = _num-_origin if _num >= _origin else (_num-_origin)/_unit
    emit_signal("trade_changed", res_type, want, _unit)


func _get_client():
    return PlayingNet.get_client()


func _get_name():
    return _get_client().get_name()