extends PopupDialog

# 连接中弹窗


const NAME: String = "LobbyConnectingPopup"


func popup_with_target(ip: String):
    $Label.text = "连接至: %s" % ip
    SceneMgr.scene_root().add_child(self)
    self.name = NAME
    popup_centered()


func _ready():
    GameServer.connect("server_accepted", self, "queue_free")
    GameServer.connect("connection_failed", self, "queue_free")


func _on_cancel():
    GameServer.close_game()
    self.queue_free()