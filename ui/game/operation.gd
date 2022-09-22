extends Control


# 操作面板


func _ready():
    pass


func init():
    _init_signal()


func _init_signal():
    _get_client().connect("client_state_changed", self, "_on_client_state_changed")


func _on_client_state_changed(state):
    if state == NetDefines.ClientState.FREE_ACTION:
        $DoneBtn.disabled = false
    else:
        $DoneBtn.disabled = true


func _get_client():
    return PlayingNet.get_client()


func _on_player_turn_done():
    _get_client().pass_turn()
