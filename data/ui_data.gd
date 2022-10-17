extends Node

class_name UI_Data


const MAPSIZE_DATA = {
    0: Data.CatanSize.SMALL,
    1: Data.CatanSize.BIG,
}


# 开关映射
const SWITCH_DATA = {
    0: '关闭',
    1: '开启',
}


# mode映射
const MODE_DATA = {
    0: "标准版",
    1: "航海家版"
}


# 位置颜色映射
const ORDER_DATA: Dictionary = {
    1: Color.red,
    2: Color.orange,
    3: Color.yellow,
    4: Color.green,
    5: Color.blue,
    6: Color.purple,
}


# 航海家地图映射
const SEAFARER_MAP_DATA = {
    Data.SeafarerMap.NEW_SHORE: "新海岸",
    Data.SeafarerMap.FOUR_ISLAND: "四岛屿",
    Data.SeafarerMap.FOG_ISLAND: "迷雾之岛",
    Data.SeafarerMap.THROUGH_DESERT: "大沙漠",
    Data.SeafarerMap.FOGGOTTEN_TRIBE: "失落之城",
}


# 图标映射数据
const ICON_DATA: Dictionary = {
    1: "res://assets/icons/aphrodite.png",
    2: "res://assets/icons/artemis.png",
    3: "res://assets/icons/athena.png",
    4: "res://assets/icons/cerberus.png",
    5: "res://assets/icons/charon.png",
    6: "res://assets/icons/demeter.png",
    7: "res://assets/icons/hades.png",
    8: "res://assets/icons/medusa.png",
    9: "res://assets/icons/megaera.png",
    10: "res://assets/icons/nyx.png",
    11: "res://assets/icons/poseidon.png",
    12: "res://assets/icons/zeus.png"
}


# 地块图片
const TILE_DATA = {
    Data.TileType.DESERT: "res://assets/tiles/desert.png",
    Data.TileType.OCEAN: "res://assets/tiles/ocean.png",
    Data.TileType.FIELD: "res://assets/tiles/field.png",
    Data.TileType.HILL: "res://assets/tiles/hill.png",
    Data.TileType.MOUNTAIN: "res://assets/tiles/mountain.png",
    Data.TileType.PASTURE: "res://assets/tiles/pasture.png",
    Data.TileType.FOREST: "res://assets/tiles/forest.png",
    Data.TileType.GOLD: "res://assets/tiles/gold.png"
}


# 点数图片
const POINT_DATA = {
    Data.PointType.TWO: "res://assets/tiles/number2.png",
    Data.PointType.THREE: "res://assets/tiles/number3.png",
    Data.PointType.FOUR: "res://assets/tiles/number4.png",
    Data.PointType.FIVE: "res://assets/tiles/number5.png",
    Data.PointType.SIX: "res://assets/tiles/number6.png",
    Data.PointType.EIGHT: "res://assets/tiles/number8.png",
    Data.PointType.NINE: "res://assets/tiles/number9.png",
    Data.PointType.TEN: "res://assets/tiles/number10.png",
    Data.PointType.ELEVEN: "res://assets/tiles/number11.png",
    Data.PointType.TWELVE: "res://assets/tiles/number12.png",
}


# 资源卡图片
const RES_DATA = {
    Data.ResourceType.LUMBER: "res://assets/cards/lumber.png",
    Data.ResourceType.WOOL: "res://assets/cards/wool.png",
    Data.ResourceType.GRAIN: "res://assets/cards/grain.png",
    Data.ResourceType.BRICK: "res://assets/cards/brick.png",
    Data.ResourceType.ORE: "res://assets/cards/ore.png",
}


# 资源图标图片
const RES_ICON_DATA = {
    Data.ResourceType.LUMBER: "res://assets/icons/lumber.png",
    Data.ResourceType.WOOL: "res://assets/icons/wool.png",
    Data.ResourceType.GRAIN: "res://assets/icons/grain.png",
    Data.ResourceType.BRICK: "res://assets/icons/brick.png",
    Data.ResourceType.ORE: "res://assets/icons/ore.png",
}

# 通用发展卡图标
const DEV_ICON_DATA = "res://assets/icons/development.png"


# 发展卡图
const CARD_DATA = {
    Data.CardType.KNIGHT: "res://assets/cards/knight.png",
    Data.CardType.VP: "res://assets/cards/vp.png",
    Data.CardType.ROAD: "res://assets/cards/road.png",
    Data.CardType.PLENTY: "res://assets/cards/year.png",
    Data.CardType.MONOPOLY: "res://assets/cards/mono.png",
}


# 卡牌名称
const CARD_NAME = {
    Data.CardType.KNIGHT: "骑士",
    Data.CardType.VP: "胜利",
    Data.CardType.ROAD: "道路",
    Data.CardType.PLENTY: "丰年",
    Data.CardType.MONOPOLY: "垄断",
}


# 建筑映射图标
const BUILDING_ICON_DATA = {
    Data.BuildingType.SETTLEMENT: "res://assets/icons/settlement.png",
    Data.BuildingType.CITY: "res://assets/icons/city.png",
    Data.BuildingType.ROAD: "res://assets/icons/road.png",
    Data.BuildingType.SHIP: "res://assets/icons/road.png",
}


# 操作按钮图标映射
const OP_BTN_DATA = {
    Data.OpType.SETTLEMENT: "res://assets/images/settlement_btn.png",
    Data.OpType.CITY: "res://assets/images/city_btn.png",
    Data.OpType.ROAD: "res://assets/images/road_btn.png",
    Data.OpType.DEV_CARD: "res://assets/images/development_btn.png"
}


# 操作按钮图标失效映射
const OP_DISABLE_DATA = {
    Data.OpType.SETTLEMENT: "res://assets/images/settlement_btn_disable.png",
    Data.OpType.CITY: "res://assets/images/city_btn_disable.png",
    Data.OpType.ROAD: "res://assets/images/road_btn_disable.png",
    Data.OpType.DEV_CARD: "res://assets/images/development_btn_disable.png"
}


# 港口图片映射
const HARBOR_DATA = {
    Data.HarborType.LUMBER: "res://assets/tiles/lumber_harbor.png",
    Data.HarborType.BRICK: "res://assets/tiles/brick_harbor.png",
    Data.HarborType.ORE: "res://assets/tiles/ore_harbor.png",
    Data.HarborType.WOOL: "res://assets/tiles/wool_harbor.png",
    Data.HarborType.GRAIN: "res://assets/tiles/grain_harbor.png",
    Data.HarborType.GENERIC: "res://assets/tiles/generic_harbor.png",
}