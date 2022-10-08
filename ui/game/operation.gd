extends Control


# 操作面板

const BankPopup: PackedScene = preload("res://ui/game/trade/bank_popup.tscn")
const TraderPopup: PackedScene = preload("res://ui/game/trade/trader_popup.tscn")
const TradedPopup: PackedScene = preload("res://ui/game/trade/traded_popup.tscn")


func init():
    _init_signal()
    _init_anim()

func _init_anim():
    $ClockBg.rect_pivot_offset = $ClockBg.rect_size/2
    $AnimationPlayer.play("rotate")
    $AnimationPlayer.stop(false)

func _init_signal():
    _get_client().connect("assist_info_changed", self, "_on_assist_info_changed")
    _get_client().connect("client_state_changed", self, "_on_client_state_changed")
    _get_client().trade_mgr.connect("trade_price_received", self, "_on_trade_price_received")


func _on_assist_info_changed(assist_info: Protocol.AssistInfo):
    _clear_popup()
    if assist_info.player_turn_name == $"/root/PlayerInfoMgr".get_self_info().player_name:
        $AnimationPlayer.play()
    else:
        $AnimationPlayer.stop(false)


func _on_trade_price_received(trade_info: Protocol.TradeInfo):
    if not _get_client().is_on_turn():
        _clear_popup()
        var trade = TradedPopup.instance()
        $PopupRoot.add_child(trade)
        trade.popup_centered()
        trade.init(trade_info)

func _clear_popup():
    for child in $PopupRoot.get_children():
        child.queue_free()


func _on_client_state_changed(state):
    _on_check_done(state)
    _on_check_city(state)
    _on_check_settlement(state)
    _on_check_road(state)
    _on_check_dev_card(state)
    _on_check_trade(state)
    _on_check_bank(state)


func _on_check_done(state):
    $DoneBtn.disabled = not (_is_free(state) or state == NetDefines.ClientState.PLAY_BEFORE_DICE)


func _is_free(state):
    return state == NetDefines.ClientState.FREE_ACTION


func _on_check_city(state):
    $City.disabled = not(_is_free(state) and _get_client().op_mgr.can_upgrade_city() and _get_client().build_mgr.get_avail_upgrade_point())


func _on_check_settlement(state):
    $Settlement.disabled = not(_is_free(state) and _get_client().op_mgr.can_place_settlement() and _get_client().build_mgr.get_turn_available_point())


func _on_check_road(state):
    $Road.disabled = not(_is_free(state) and _get_client().op_mgr.can_place_road() and _get_client().build_mgr.get_turn_available_road())


func _on_check_dev_card(state):
    $DevCard.disabled = not(_is_free(state) and _get_client().op_mgr.can_buy_dev() and _get_client().bank_info.avail_card > 0)


func _on_check_bank(state):
    $Bank.disabled = not _is_free(state)


func _on_check_trade(state):
    $Trade.disabled = not (_is_free(state) and _get_client().is_have_res())


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
    _get_client().request_buy_dev_card()


func _on_trade_with_bank():
    var bank = BankPopup.instance()
    $PopupRoot.add_child(bank)
    bank.popup_centered()


func _on_trade_with_player():
    var trade = TraderPopup.instance()
    $PopupRoot.add_child(trade)
    trade.popup_centered()


