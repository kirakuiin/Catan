extends Control


# 银行信息显示


func init():
    _init_signal()

func _init_signal():
    PlayingNet.get_client().connect("bank_info_changed", self, "_on_bank_info_changed")


func _on_bank_info_changed(bank_info: Protocol.BankInfo):
    $Box/Brick/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.BRICK])
    $Box/Wool/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.WOOL])
    $Box/Lumber/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.LUMBER])
    $Box/Ore/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.ORE])
    $Box/Grain/Label.bbcode_text = _get_bbcode(bank_info.res_info[Data.ResourceType.GRAIN])
    $Dev/Label.bbcode_text = _get_bbcode(bank_info.avail_card)

func _get_bbcode(num: int) -> String:
    var color = "white"
    if num == 0:
        color = "red"
    return "[center][color=%s]%d[/color][/center]" % [color, num]