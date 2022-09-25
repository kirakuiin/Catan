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
const ROLL_TIME: float = 1.5


# 玩家状态枚举
class PlayerState:
    extends Reference

    const NOT_READY: String="未就绪"
    const READY: String="就绪"
    const WAIT_FOR_RESPONE: String="等待回应"
    const DONE: String="操作结束"
    const PASS: String="回合让过"


# 玩家操作状态枚举
class PlayerOpState:
    extends Reference

    const NONE: String="无操作"
    const BUILD_SETTLEMENT: String="建造定居点"
    const BUILD_ROAD: String="建造道路"
    const UPGRADE_CITY: String="升级城市"
    const BUY_DEV_CARD: String="购买发展卡"


# 客户端状态枚举
class ClientState:
    extends Reference

    const IDLE: String="空闲"
    const PLACE_SETTLEMENT_SETUP: String="放置初始定居点"
    const PLACE_SETTLEMENT_TURN: String="放置回合定居点"
    const PLACE_ROAD_SETUP: String="放置初始道路"
    const PLACE_ROAD_TURN: String="放置回合道路"
    const UPGRADE_CITY: String="升级城市"
    const FREE_ACTION: String="自由行动"
    const DISCARD_RESOURCE: String="丢弃资源"
    const MOVE_ROBBER: String="移动强盗"
    const ROB_PLAYER: String="抢劫玩家"