extends Control


# 游戏中提示信息


const BULLET_NUM: int = 6
const PLAY_TIME: int = 5000
const Bullet: PackedScene = preload("res://ui/game/info/bullet_info.tscn")
const ResPop: PackedScene = preload("res://ui/game/info/res_popup.tscn")

var _bullet_track: Array
var _assist_info: Protocol.AssistInfo = Protocol.AssistInfo.new()


func init():
    _init_track()
    _init_signal()


func _init_track():
    for _i in BULLET_NUM:
        _bullet_track.append(-INF)


func _init_signal():
    _get_client().connect("assist_info_changed", self, "_on_assist_info_changed")
    _get_client().connect("player_hint_showed", self, "_on_player_hint_showed")
    _get_client().connect("client_state_changed", self, "_on_client_state_changed")
    _get_client().connect("notification_received", self, "_on_notification_received")


func _get_client():
    return PlayingNet.get_client()


func _on_assist_info_changed(assist_info: Protocol.AssistInfo):
    _show_player_turn(assist_info.player_turn_name)
    _show_turn_info(assist_info.turn_num)
    _show_turn_phase(assist_info.turn_phase)
    _assist_info = assist_info


func _show_player_turn(player_name: String):
    if _assist_info.player_turn_name != player_name:
        var color = _get_client().get_color(player_name)
        $PlayerTurn.add_color_override("font_color", color)
        $PlayerTurn.text = "玩家[%s]行动..." % player_name
        $TurnPlayer.stop()
        $TurnPlayer.play("popup")


func _show_turn_info(turn_num: int):
    if turn_num == 0:
        $Turn.text = "布置阶段"
    else:
        $Turn.text = "回合[%d]" % turn_num


func _show_turn_phase(phase: String):
    var color = Color.white
    match phase:
        NetDefines.TurnPhase.ROLL:
            color = Color.orangered
        NetDefines.TurnPhase.MAIN:
            color = Color.lime
        NetDefines.TurnPhase.SPECIAL_BUILDING:
            color = Color.aquamarine
    $Phase.bbcode_text = "[center][color=%s]%s[/color][/center]" % [Util.color_to_str(color), phase]


func _on_player_hint_showed(hint: String, is_always_show: bool):
    $SingleInfo.show()
    $SingleInfo.text = hint
    if not is_always_show:
        $HintPlayer.stop()
        $HintPlayer.play("show_hint")
    else:
        $HintPlayer.play("RESET")


func _on_client_state_changed(state: String, params: Dictionary):
    $SingleInfo.hide()
    _create_popup(state)

func _create_popup(state: String):
    var popup = ResPop.instance()
    add_child(popup)
    if state == NetDefines.ClientState.CHOOSE_MONO_TYPE:
        popup.popup_choose_mono_type()
    elif state == NetDefines.ClientState.CHOOSE_RES:
        popup.popup_choose_res()


func _on_notification_received(noti_info: Protocol.NotificationInfo):
    var bullet = Bullet.instance()
    _init_bullet_info(bullet)
    $BulletZone.add_child(bullet)
    var message = Message.notification_to_message(noti_info)
    if message.has_content():
        bullet.play_with_msg(message.bbcode())

func _init_bullet_info(bullet):
    var space = $BulletZone.rect_size.y/BULLET_NUM
    var track = _find_available_track()
    bullet.rect_position.y = track*space
    _bullet_track[track] = Time.get_ticks_msec()

func _find_available_track():
    var min_time = INF
    var min_track = -1
    for i in BULLET_NUM:
        if Time.get_ticks_msec()-_bullet_track[i] > PLAY_TIME:
            return i
        if _bullet_track[i] < min_time:
            min_time = _bullet_track[i]
            min_track = i
    return min_track