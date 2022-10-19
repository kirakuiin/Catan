extends Node

# 用于定义网络相关常量

class_name NetDefines


const BROADCAST_ADDR: String = "255.255.255.255"
const SERVER_NAME: String = "CatanServer"
const CLIENT_NAME: String = "CatanClient"
const TRADE_CENTER: String = "TradeCenter"
const BROAD_PORT: int = 12345
const GAME_PORT: int = 32323
const MAX_PEER: int = 5
const SERVER_ID: int = 1
const ROLL_TIME: float = 2.0


# 玩家网络状态枚举
class PlayerNetState:
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
    const PLAY_CARD: String="打出卡牌"
    const TRADE: String="交易"


# 玩家操作结构
class PlayerOpStruct:
    extends Reference

    var state: String
    var params: Array

    func _init(s: String=PlayerOpState.NONE, p: Array=[]):
        state = s
        params = p


# 客户端状态枚举
class ClientState:
    extends Reference

    const IDLE: String="空闲"
    const FREE_ACTION: String="自由行动"
    const SPECIAL_BUILDING: String="特殊建造阶段"
    const PLAY_BEFORE_DICE: String="投掷前出牌"
    const PLACE_SETTLEMENT_SETUP: String="放置初始定居点"
    const PLACE_SETTLEMENT_TURN: String="放置回合定居点"
    const PLACE_ROAD_SETUP: String="放置初始道路"
    const PLACE_ROAD_TURN: String="放置回合道路"
    const UPGRADE_CITY: String="升级城市"
    const DISCARD_RESOURCE: String="丢弃资源"
    const MOVE_ROBBER: String="移动强盗"
    const ROB_PLAYER: String="抢劫玩家"
    const CHOOSE_RES: String="选择获得资源"
    const CHOOSE_MONO_TYPE: String="选择垄断类型"


# 交易状态枚举
class TradeState:
    extends Reference

    const NEGOTIATE: String="协商"
    const AGREE: String="同意"
    const REFUSE: String="拒绝"


# 通告枚举
enum NotificationType {
    NONE,
    TRADE_RESOURCE,
    DISCARD_RESOURCE,
    LOST_RESOURCE,
    GET_RESOURCE,
    ROAD_ARCHIEVEMENT,
    ARMY_ARCHIEVEMENT,
    PLACE_SETTLEMENT,
    PLACE_ROAD,
    UPGRADE_CITY,
    MOVE_ROBBER,
    PLAYER_ROBBED,
    PLAY_CARD,
    BUY_CARD,
}