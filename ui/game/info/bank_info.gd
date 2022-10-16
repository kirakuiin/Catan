extends Control


# 银行信息显示


func init():
    _init_signal()

func _init_signal():
    PlayingNet.get_client().connect("bank_info_changed", self, "_on_bank_info_changed")


func _on_bank_info_changed(bank_info: Protocol.BankInfo):
    var data = Data.SETTLER_DATA[PlayingNet.get_client().setup_info.catan_size].resource.each_num
    $Box/Brick/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.BRICK], data[Data.ResourceType.BRICK])
    $Box/Wool/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.WOOL], data[Data.ResourceType.WOOL])
    $Box/Lumber/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.LUMBER], data[Data.ResourceType.LUMBER])
    $Box/Ore/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.ORE], data[Data.ResourceType.ORE])
    $Box/Grain/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.GRAIN], data[Data.ResourceType.GRAIN])
    $Dev/Label.bbcode_text = _get_bbcode(bank_info.avail_card, Data.SETTLER_DATA[PlayingNet.get_client().setup_info.catan_size].card.total_num)

func _get_bbcode(num: int, total: int) -> String:
    var color = "white"
    if num == 0:
        color = Util.color_to_str(Color.red)
    elif num == total:
        color = Util.color_to_str(Color.lime)
    return "[center][color=%s]%d/%d[/color][/center]" % [color, num, total]