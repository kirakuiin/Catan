extends AudioStreamPlayer


# 游戏主界面

const DRAW_CARD: AudioStream = preload("res://assets/audios/draw_card.wav")
const PLAY_CARD: AudioStream = preload("res://assets/audios/play_card.wav")
const JOB_DONE: AudioStream = preload("res://assets/audios/job_done.wav")
const UPGRADE_DONE: AudioStream = preload("res://assets/audios/upgrade_finished.wav")
const KNIGHT_MOVE: AudioStream = preload("res://assets/audios/knight_move.wav")
const PLACE_ROAD: AudioStream = preload("res://assets/audios/place_road.wav")
const PLAYER_ROBBED: AudioStream = preload("res://assets/audios/player_robbed.wav")
const FAN_FARE: AudioStream = preload("res://assets/audios/fanfare.mp3")


func init():
    PlayingNet.get_client().connect("notification_received", self, "_on_notification_received")
    PlayingNet.get_client().connect("stat_info_received", self, "_on_stat_info_received")


func _on_notification_received(noti_info: Protocol.NotificationInfo):
    if noti_info.notify_type == NetDefines.NotificationType.BUY_CARD:
        Audio.play_once(self, DRAW_CARD)
    elif noti_info.notify_type == NetDefines.NotificationType.PLACE_ROAD:
        Audio.play_once(self, PLACE_ROAD)
    elif noti_info.notify_type == NetDefines.NotificationType.PLACE_SETTLEMENT:
        Audio.play_once(self, JOB_DONE)
    elif noti_info.notify_type == NetDefines.NotificationType.UPGRADE_CITY:
        Audio.play_once(self, UPGRADE_DONE)
    elif noti_info.notify_type == NetDefines.NotificationType.MOVE_ROBBER:
        Audio.play_once(self, KNIGHT_MOVE)
    elif noti_info.notify_type == NetDefines.NotificationType.PLAYER_ROBBED:
        Audio.play_once(self, PLAYER_ROBBED)
    elif noti_info.notify_type == NetDefines.NotificationType.PLAY_CARD:
        Audio.play_once(self, PLAY_CARD)


func _on_stat_info_received(stat_info: Protocol.StatInfo):
    Audio.play_once(self, FAN_FARE)