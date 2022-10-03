extends Node

# 音频管理

const BG_MUSIC: AudioStreamMP3 = preload("res://assets/audios/main_theme.mp3")
#const GAME_MUSIC: AudioStreamMP3


onready var _audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
onready var _logger: Log.Logger = Log.get_logger(Log.LogModule.AUDIO)


func _ready():
    _audio_player.bus = "Background"
    add_child(_audio_player)


# 播放背景音乐
func play_bg():
    _logger.logi("开始播放背景音乐")
    _audio_player.stream = BG_MUSIC
    _audio_player.play()


# 播放游戏中背景
func play_game_bg():
    _logger.logi("开始播放游戏音乐")
    _audio_player.stream = BG_MUSIC
    _audio_player.play()


# 停止播放背景音乐
func stop_bg():
    _audio_player.stop()
