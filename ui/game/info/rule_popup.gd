extends PopupDialog

const Item: PackedScene = preload("res://ui/game/info/rule_item.tscn")


func init_popup():
    var setup = _get_client().setup_info
    if setup.special_bd:
        _add_item(Data.RuleType.SPECIAL_BUILD)
    if setup.is_seafarer():
        _add_item(Data.RuleType.SEAFARER)


func have_rule() -> bool:
    return $Scroll/VCon.get_child_count() > 0


func _on_confirm():
    hide()


func _add_item(rule_type: int):
    var item = Item.instance()
    item.init(rule_type)
    $Scroll/VCon.add_child(item)


func _get_client():
    return PlayingNet.get_client()