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


# 规则映射
const RULE_DATA: Dictionary = {
    Data.RuleType.SPECIAL_BUILD: {
        "title": "特殊建造阶段",
        "color": Color.cyan,
        "desc": "每个玩家的回合结束, 其他玩家按顺序依次进入特殊建造阶段, 在此阶段只能进行建造和购买发展卡, 所有其他玩家的特殊建造阶段结束后进入下一个玩家的回合.",
    },
    Data.RuleType.FIXED_START: {
        "title": "固定起点",
        "color": Color.purple,
        "desc": "只能在特定的区域建立初始定居点"
    },
    Data.RuleType.SEAFARER: {
        "title": "航海家",
        "color": Color.aqua,
        "desc": "1. 在沿海区域修建定居点可以建造船路(建造于海洋方格上), \n2. 投掷7点时可以在移动强盗和移动海盗中选择一个. 被海盗占据的方格无法建造船路, 并且可以抢劫方格上有航路的玩家.\n3. 世界中如果存在金矿, 投掷到对应点数时可以挑选任意类型的资源."
    },
    Data.RuleType.EXPLORE: {
        "title": "探索",
        "color": Color.orangered,
        "desc": "每当揭示一个迷雾地块, 都将获得此地块上的一个资源(海洋和沙漠不会).",
    },
    Data.RuleType.COLONIZE: {
        "title": "殖民",
        "color": Color.lime,
        "desc": "每当在一个新的岛屿上建立定居点, 额外获得一点胜点.",
    }
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
    Data.TileType.GOLD: "res://assets/tiles/gold.png",
    Data.TileType.NULL: "res://assets/tiles/empty.png",
    Data.TileType.RANDOM: "res://assets/tiles/tile_random.png"
}


# 点数图片
const POINT_DATA = {
    Data.PointType.ZERO: "res://assets/tiles/number0.png",
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
    Data.PointType.RANDOM: "res://assets/tiles/point_random.png",
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
    Data.HarborType.NULL: "res://assets/tiles/null_harbor.png",
    Data.HarborType.RANDOM: "res://assets/tiles/random_harbor.png"
}


# 地形图片映射
const LANDFORM_DATA = {
    Data.LandformType.CLOUD: "res://assets/images/cloud.png",
    Data.LandformType.SETTLEMENT: "res://assets/images/start_flag.png"
}


# 背景音乐映射
const BG_DATA = {
    0: "CivilizationVI",
    1: "P5",
    2: "P5R",
}

const BG_MUSIC = {
    "CivilizationVI": "res://assets/audios/game_theme.mp3",
    "P5": "res://assets/audios/groovy.mp3",
    "P5R": "res://assets/audios/life_will_change.mp3",
}