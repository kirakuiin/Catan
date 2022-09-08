extends Control

var _player_name: String


func init(player_info: Protocol.PlayerInfo):
    _player_name = player_info.player_name
    if player_info.peer_id != NetDefines.SERVER_ID:
        $HBoxContainer/HostFlagTexture.texture = null
    $HBoxContainer/PlayerNameLabel.text = player_info.player_name
    $HBoxContainer/PlayerAvatorTexture.texture = ResourceLoader.load(Data.ICON_DATA[player_info.icon_id])


func get_player_name() -> String:
    return _player_name
