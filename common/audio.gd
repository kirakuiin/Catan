extends Node

# 音频管理

const BG_MUSIC: AudioStreamMP3 = preload("res://assets/audios/main_theme.mp3")
const GAME_MUSIC: AudioStreamMP3 = preload("res://assets/audios/game_theme.mp3")


onready var _audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
onready var _logger: Log.Logger = Log.get_logger(Log.LogModule.AUDIO)


# 播放wav一次
static func play_once(player: AudioStreamPlayer, stream: AudioStream):
    if stream is AudioStreamSample:
        stream.loop_mode = AudioStreamSample.LOOP_DISABLED
    elif stream is AudioStreamMP3:
        stream.loop = false
    player.stream = stream
    player.play()


func _ready():
    _audio_player.bus = "Background"
    add_child(_audio_player)
    _init_db()


func _init_db():
    set_master_volume(GameConfig.get_master_volume())
    set_bg_volume(GameConfig.get_bg_volume())
    set_effect_volume(GameConfig.get_effect_volume())


# 播放背景音乐
func play_bg():
    _logger.logi("开始播放背景音乐")
    _audio_player.stream = BG_MUSIC
    _audio_player.play()


# 播放游戏中背景
func play_game_bg():
    _logger.logi("开始播放游戏音乐")
    _audio_player.stream = GAME_MUSIC
    _audio_player.play()


# 停止播放背景音乐
func stop_bg():
    _audio_player.stop()


# 设置背景音量
func set_bg_volume(volume: int):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background"), linear2db(volume/100.0))


# 设置音效音量
func set_effect_volume(volume: int):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effect"), linear2db(volume/100.0))


# 设置主音量
func set_master_volume(volume: int):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(volume/100.0))
