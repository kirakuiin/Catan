extends Node

# 用于定义网络相关常量

class_name NetDefines


const BROADCAST_ADDR: String = "255.255.255.255"
const SERVER_NAME: String = "CatanServer"
const CLIENT_NAME: String = "CatanClient"
const BROAD_PORT: int = 12345
const GAME_PORT: int = 32323
const MAX_PEER: int = 5
const SERVER_ID: int = 1


enum PlayerOpState {
    NOT_READY,  # 未就绪
    READY,   # 就绪
    WAIT_RESPONSS,  # 等待回应
    PLACE_SETTLEMENT_DONE,  # 放置定居点完毕
    PLACE_ROAD_DONE,  # 放置道路完毕
}