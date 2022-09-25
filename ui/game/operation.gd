extends Control


# 操作面板


func _ready():
    pass


func init():
    _init_signal()


func _init_signal():
    _get_client().connect("client_state_changed", self, "_on_client_state_changed")


func _on_client_state_changed(state):
    _on_check_done(state)  # TODO: 更加明显的让过按钮
    _on_check_city(state)
    _on_check_settlement(state)
    _on_check_road(state)
    _on_check_dev_card(state)


func _on_check_done(state):
    $DoneBtn.disabled = not _is_free(state)


func _is_free(state):
    return state == NetDefines.ClientState.FREE_ACTION


func _on_check_city(state):
    $City.disabled = not(_is_free(state) and _get_client().op_mgr.can_upgrade_city() and _get_client().build_mgr.get_avail_upgrade_point())


func _on_check_settlement(state):
    $Settlement.disabled = not(_is_free(state) and _get_client().op_mgr.can_place_settlement() and _get_client().build_mgr.get_turn_available_point())


func _on_check_road(state):
    $Road.disabled = not(_is_free(state) and _get_client().op_mgr.can_place_road() and _get_client().build_mgr.get_turn_available_road())


func _on_check_dev_card(state):
    $DevCard.disabled = not(_is_free(state) and _get_client().op_mgr.can_buy_dev())


func _get_client():
    return PlayingNet.get_client()


func _on_player_turn_done():
    _get_client().pass_turn()


func _on_place_road():
    _get_client().request_place_road()


func _on_upgrade_city():
    _get_client().request_upgrade_city()


func _on_place_settlement():
    _get_client().request_place_settlement()


func _on_buy_dev_card():
	pass # Replace with function body.
