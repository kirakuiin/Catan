extends PopupDialog


# 银行交易弹窗

var _trade_info: Dictionary
var _trade_unit: Dictionary


# 初始化
func _ready():
    _init_unit_label()

func _init_unit_label():
    _init_generic()
    _init_other_type()
    _init_balance()

func _init_generic():
    var types = _get_client().build_mgr.get_all_harbor_type()
    if types.contains(Data.HarborType.GENERIC):
        var unit = Data.HARBOR_UNIT[Data.HarborType.GENERIC]
        for label in $TitleCon.get_children():
            label.text = "%d:1" % unit

func _init_other_type():
    var types = _get_client().build_mgr.get_all_harbor_type()
    for type in types.values():
        var unit = Data.HARBOR_UNIT[type]
        var text = "%d:1" % unit
        match type:
            Data.HarborType.LUMBER:
                $TitleCon/Lumber.text = text
            Data.HarborType.BRICK:
                $TitleCon/Brick.text = text
            Data.HarborType.ORE:
                $TitleCon/Ore.text = text
            Data.HarborType.GRAIN:
                $TitleCon/Grain.text = text
            Data.HarborType.WOOL:
                $TitleCon/Wool.text = text

func _init_balance():
    $Balance/Pole.rect_pivot_offset = Vector2($Balance/Pole.rect_size.x/2, $Balance/Pole.rect_size.y-1)


func _on_cancel():
    queue_free()


func _on_confirm():
    queue_free()
    _get_client().request_trade(_get_trade_info())

func _get_trade_info() -> Protocol.TradeInfo:
    var result = _trade_info.duplicate(true)
    for res_type in result:
        if result[res_type] < 0:
            result[res_type] *= _trade_unit[res_type]
    var trade_info = Protocol.TradeInfo.new(_get_name())
    trade_info.init_by_dict(result)
    return trade_info


func _get_client():
    return PlayingNet.get_client()


func _get_name():
    return _get_client().get_name()


func _on_trade_changed(res_type: int, num: int, unit: int):
    _trade_info[res_type] = num
    _trade_unit[res_type] = unit
    var total = StdLib.sum(_trade_info.values())
    _set_balance(total)
    var abs_total = 0
    for val in _trade_info.values():
        abs_total += abs(val)
    $Confirm.disabled = (total != 0 or abs_total == 0)


func _set_balance(num: int):
    $Balance/Pole.rect_rotation = clamp(-num*5, -30, 30)