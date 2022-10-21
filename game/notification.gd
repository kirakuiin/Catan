extends Reference

# 通告

class_name Notification


# 得到放置道路通告
static func place_road(player: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.PLACE_ROAD, {"player": player})


# 得到放置定居点
static func place_settlement(player: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.PLACE_SETTLEMENT, {"player": player})


# 得到升级城市通告
static func upgrade_city(player: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.UPGRADE_CITY, {"player": player})


# 得到移动强盗通告
static func move_robber(player: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.MOVE_ROBBER, {"player": player})



# 玩家被抢劫
static func player_robbed(robber: String, robbed: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.PLAYER_ROBBED, {"robber": robber, "robbed": robbed})


# 得到购买卡牌通告
static func buy_card(player: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.BUY_CARD, {"player": player})


# 得到打出卡牌通告
static func play_card(player: String, dev_type: int) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.PLAY_CARD, {"player": player, "dev_type": dev_type})


# 军队成就
static func army_archievement(player: String, is_get: bool) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.ARMY_ARCHIEVEMENT, {"player": player, "is_get": is_get})


# 道路成就
static func road_archievement(player: String, is_get: bool) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.ROAD_ARCHIEVEMENT, {"player": player, "is_get": is_get})


# 交易
static func trade_res(trade_info: Protocol.TradeInfo) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.TRADE_RESOURCE, {"trade_info": trade_info})


# 弃牌
static func discard_res(player: String, res_info: Dictionary) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.DISCARD_RESOURCE, {"player": player, "res_info": res_info})


# 丢失资源
static func lost_res(player: String, res_info: Dictionary) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.LOST_RESOURCE, {"player": player, "res_info": res_info})


# 得到资源
static func get_res(player: String, res_info: Dictionary) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.GET_RESOURCE, {"player": player, "res_info": res_info})


# 特殊建造阶段
static func special_building(player: String) -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(
        NetDefines.NotificationType.SPECIAL_BUILDING, {"player": player})