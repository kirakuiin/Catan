extends Control

# 弹幕


# 播放弹幕
func play_with_msg(bbcode: String):
    $Message.bbcode_text = bbcode
    $AnimationPlayer.play("fly")