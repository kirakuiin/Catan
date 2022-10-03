extends Reference

# 通告

class_name Notification


# 得到放置道路通告
static func place_road() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.PLACE_ROAD)


# 得到放置定居点
static func place_settlement() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.PLACE_SETTLEMENT)


# 得到升级城市通告
static func upgrade_city() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.UPGRADE_CITY)


# 得到移动强盗通告
static func move_robber() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.MOVE_ROBBER)


# 玩家被抢劫
static func player_robbed() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.PLAYER_ROBBED)


# 得到购买卡牌通告
static func buy_card() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.BUY_CARD)


# 得到打出卡牌通告
static func play_card() -> Protocol.NotificationInfo:
    return Protocol.NotificationInfo.new(NetDefines.NotificationType.PLAY_CARD)