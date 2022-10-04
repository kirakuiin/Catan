extends Control


# 音量设置


func _ready():
    $VCon/Master/HSlider.value = GameConfig.get_master_volume()
    $VCon/Bg/HSlider.value = GameConfig.get_bg_volume()
    $VCon/Effect/HSlider.value = GameConfig.get_effect_volume()


func _on_master_changed(volume: int):
    GameConfig.set_master_volume(volume)
    Audio.set_master_volume(volume)


func _on_bg_changed(volume: int):
    GameConfig.set_bg_volume(volume)
    Audio.set_bg_volume(volume)


func _on_effect_changed(volume: int):
    GameConfig.set_effect_volume(volume)
    Audio.set_effect_volume(volume)
