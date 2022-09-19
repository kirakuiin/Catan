extends Control


# 操作面板


func _ready():
    pass

func _on_layer_turn_done():
    PlayingNet.get_client().pass_turn()