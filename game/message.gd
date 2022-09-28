extends Reference

# 消息

class_name Message


# 得到弃牌消息
static func discard(player_name: String, discard_info: Dictionary) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text(" 丢弃资源: ")
    for res_type in discard_info:
        if discard_info[res_type] > 0:
            message.add_resource(res_type)
            message.add_text("[%d] " % discard_info[res_type])
    return message


# 得到放置定居点消息
static func place_settlement(player_name: String) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text("放置新定居点")
    message.add_building(Data.BuildingType.SETTLEMENT)
    return message


# 得到升级城市消息
static func place_city(player_name: String) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text("升级城市")
    message.add_building(Data.BuildingType.CITY)
    return message


# 得到放置道路消息
static func place_road(player_name: String) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text("放置道路")
    message.add_building(Data.BuildingType.ROAD)
    return message


# 得到升级城市消息
static func upgrade_city(player_name: String) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text("升级城市")
    message.add_building(Data.BuildingType.CITY)
    return message


# 得到购买卡牌消息
static func buy_dev_card(player_name: String) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text("购买发展卡")
    message.add_buy_dev()
    return message


# 得到分配资源消息
static func dispatch_res(player_name: String, res_info: Dictionary) -> Protocol.MessageInfo:
    var message = Protocol.MessageInfo.new()
    message.add_player(player_name)
    message.add_text("收获资源: ")
    for res_type in res_info:
        message.add_resource(res_type)
        message.add_text("[%d] " % res_info[res_type])
    return message


# 得到抢劫消息
static func rob_player(from: String, to: String):
    var message = Protocol.MessageInfo.new()
    message.add_player(from)
    message.add_text(" 抢劫了 ")
    message.add_player(to)
    return message


# 打出卡牌
static func play_card(player: String, dev_type: int):
    var message = Protocol.MessageInfo.new()
    message.add_player(player)
    message.add_text(" 打出发展卡")
    message.add_development(dev_type)
    message.add_text("[%s]" % [Data.CARD_NAME[dev_type]])
    return message