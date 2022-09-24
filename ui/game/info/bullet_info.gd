extends Control

# 弹幕


# 播放弹幕
func play_with_msg(message: Protocol.MessageInfo):
    $Message.bbcode_text = message.bbcode(PlayingNet.get_client().order_info)
    $AnimationPlayer.play("fly")