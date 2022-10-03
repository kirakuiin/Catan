extends Reference

# 消息

class_name Message


# 消息信息
class RichMessage:
    const TEXT: int = 1
    const PLAYER: int = 2
    const RES: int = 3
    const DEV: int = 4
    const BUILDING: int = 5
    const BUY_DEV: int = 6
    const ARMY_ARCH: int = 7
    const ROAD_ARCH: int = 8

    var message_list: Array

    func _init(msg_list: Array=[]):
        message_list = msg_list

    # 是否有内容
    func has_content() -> bool:
        return bool(len(message_list))

    # 追加普通信息
    func add_text(text):
        message_list.append({TEXT: text})

    # 追加玩家
    func add_player(name: String):
        message_list.append({PLAYER: name})

    # 追加购买发展卡
    func add_buy_dev():
        message_list.append({BUY_DEV: 1})

    # 追加资源文本
    func add_resource(res_type: int):
        message_list.append({RES: res_type})

    # 追加建筑文本
    func add_building(building_type: int):
        message_list.append({BUILDING: building_type})

    # 追加发展卡文本
    func add_development(dev_type: int):
        message_list.append({DEV: dev_type})

    # 追加军队成就文本
    func add_army_archievement(is_get: bool):
        message_list.append({ARMY_ARCH: is_get})

    # 追加道路成就文本
    func add_road_archievement(is_get: bool):
        message_list.append({ROAD_ARCH: is_get})

    # 转为bbcode
    func bbcode() -> String:
        var result = PoolStringArray()
        for sub_msg in message_list:
            var type = sub_msg.keys()[0]
            var val = sub_msg.values()[0]
            result.append(_parse(type, val))
        return "".join(result)
    
    func _parse(type:int , val) -> String:
        var result = ""
        match type:
            TEXT:
                result = "[valign px=10]%s[/valign]" % str(val)
            PLAYER:
                if val == Protocol.TradeInfo.BANK:
                    result = "[valign px=10][color=silver]%s[/color][/valign]" % "银行"
                else:
                    result = "[valign px=10][color=%s]%s[/color][/valign]" % [Util.color_to_str(PlayingNet.get_client().get_color(val)), val]
            RES:
                result = "[img=50x50]%s[/img]" % Data.RES_ICON_DATA[val]
            BUILDING:
                result = "[img=50x50]%s[/img]" % Data.BUILDING_ICON_DATA[val]
            DEV:
                result = "[img=50x50]%s[/img]" % Data.DEV_ICON_DATA
            BUY_DEV:
                result = "[img=50x50]%s[/img]" % Data.DEV_ICON_DATA
            ARMY_ARCH:
                if val:
                    result = "获得[shake rate=10 level=30][color=silver]成就[/color][/shake] [[rainbow freq=0.2 sat=10 val=20]最多军队[/rainbow]]"
                else:
                    result = "丢失[shake rate=10 level=30][color=silver]成就[/color][/shake] [[color=grey][tornado radius=5 freq=3]最多军队[/tornado][/color]]"
            ROAD_ARCH:
                if val:
                    result = "获得[shake rate=10 level=30][color=silver]成就[/color][/shake] [[rainbow freq=0.2 sat=10 val=20]最长连续道路[/rainbow]]"
                else:
                    result = "丢失[shake rate=10 level=30][color=silver]成就[/color][/shake] [[color=grey][tornado radius=5 freq=3]最长连续道路[/tornado][/color]]"
        return result
            

static func notification_to_message(noti_info: Protocol.NotificationInfo) -> RichMessage:
    var message = RichMessage.new()
    var info = noti_info.notify_params
    match noti_info.notify_type:
        NetDefines.NotificationType.PLACE_ROAD:
            message = place_road(info.player)
        NetDefines.NotificationType.PLACE_SETTLEMENT:
            message = place_settlement(info.player)
        NetDefines.NotificationType.UPGRADE_CITY:
            message = upgrade_city(info.player)
        NetDefines.NotificationType.GET_RESOURCE:
            message = get_res(info.player, info.res_info)
        NetDefines.NotificationType.DISCARD_RESOURCE:
            message = discard_res(info.player, info.res_info)
        NetDefines.NotificationType.LOST_RESOURCE:
            message = lost_res(info.player, info.res_info)
        NetDefines.NotificationType.BUY_CARD:
            message = buy_card(info.player)
        NetDefines.NotificationType.PLAY_CARD:
            message = play_card(info.player, info.dev_type)
        NetDefines.NotificationType.PLAYER_ROBBED:
            message = player_robbed(info.robber, info.robbed)
        NetDefines.NotificationType.ARMY_ARCHIEVEMENT:
            message = army_archievement(info.player, info.is_get)
        NetDefines.NotificationType.ROAD_ARCHIEVEMENT:
            message = road_archievement(info.player, info.is_get)
        NetDefines.NotificationType.TRADE_RESOURCE:
            message = trade_res(info.trade_info)
    return message


# 得到放置道路消息
static func place_road(player_name: String) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    message.add_text("放置道路")
    message.add_building(Data.BuildingType.ROAD)
    return message


# 得到放置定居点消息
static func place_settlement(player_name: String) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    message.add_text("放置新定居点")
    message.add_building(Data.BuildingType.SETTLEMENT)
    return message


# 得到升级城市消息
static func upgrade_city(player_name: String) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    message.add_text("升级城市")
    message.add_building(Data.BuildingType.CITY)
    return message


# 得到分配资源消息
static func get_res(player_name: String, res_info: Dictionary) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    if res_info:
        message.add_text("得到资源: ")
        for res_type in res_info:
            message.add_resource(res_type)
            message.add_text("[%d] " % res_info[res_type])
    else:
        message.add_text("没有得到资源.")
    return message


# 得到弃牌消息
static func discard_res(player_name: String, discard_info: Dictionary) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    message.add_text(" 丢弃资源: ")
    for res_type in discard_info:
        if discard_info[res_type] > 0:
            message.add_resource(res_type)
            message.add_text("[%d] " % discard_info[res_type])
    return message


# 失去资源信息
static func lost_res(player_name: String, res_info: Dictionary) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    message.add_text("失去资源: ")
    for res_type in res_info:
        message.add_resource(res_type)
        message.add_text("[%d] " % res_info[res_type])
    return message


# 得到购买卡牌消息
static func buy_card(player_name: String) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player_name)
    message.add_text("购买发展卡")
    message.add_buy_dev()
    return message


# 打出卡牌
static func play_card(player: String, dev_type: int) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player)
    message.add_text(" 打出发展卡")
    message.add_development(dev_type)
    message.add_text("[%s]" % [Data.CARD_NAME[dev_type]])
    return message


# 得到抢劫消息
static func player_robbed(from: String, to: String) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(from)
    message.add_text(" 抢劫了 ")
    message.add_player(to)
    return message


# 军队成就
static func army_archievement(player: String, is_get: bool=true) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player)
    message.add_army_archievement(is_get)
    return message


# 道路成就
static func road_archievement(player: String, is_get: bool=true) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(player)
    message.add_road_archievement(is_get)
    return message


# 交易消息
static func trade_res(trade_info: Protocol.TradeInfo) -> RichMessage:
    var message = RichMessage.new()
    message.add_player(trade_info.from_player)
    message.add_text(" 同 ")
    message.add_player(trade_info.to_player)
    message.add_text(" 交易")
    return message