extends Node


class_name Data


# 主机状态
enum HostState {PREPARE, PLAYING}


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


# 位置颜色映射
const ORDER_DATA: Dictionary = {
    1: Color.red,
    2: Color.orange,
    3: Color.yellow,
    4: Color.green,
    5: Color.blue,
    6: Color.purple,
}


# 玩家数量映射
enum CatanSize {BIG=6, SMALL=4}


const MAPSIZE_DATA = {
    0: CatanSize.SMALL,
    1: CatanSize.BIG,
}


# 开关映射
const SWITCH_DATA = {
    0: '关闭',
    1: '开启',
}


# 地块映射
enum TileType{DESERT, FIELD, HILL, MOUNTAIN, PASTURE, FOREST, OCEAN}


const TILE_DATA = {
    TileType.DESERT: "res://assets/tiles/desert.png",
    TileType.OCEAN: "res://assets/tiles/ocean.png",
    TileType.FIELD: "res://assets/tiles/field.png",
    TileType.HILL: "res://assets/tiles/hill.png",
    TileType.MOUNTAIN: "res://assets/tiles/mountain.png",
    TileType.PASTURE: "res://assets/tiles/pasture.png",
    TileType.FOREST: "res://assets/tiles/forest.png",
}



# 成就映射
enum AchievementType{ARMY, ROAD}


# 点数映射
enum PointType{ZERO=0, TWO=2, THREE=3, FOUR=4, FIVE=5, SIX=6, SEVEN=7, EIGHT=8, NINE=9, TEN=10, ELEVEN=11, TWELVE=12}


const POINT_DATA = {
    PointType.TWO: "res://assets/tiles/number2.png",
    PointType.THREE: "res://assets/tiles/number3.png",
    PointType.FOUR: "res://assets/tiles/number4.png",
    PointType.FIVE: "res://assets/tiles/number5.png",
    PointType.SIX: "res://assets/tiles/number6.png",
    PointType.EIGHT: "res://assets/tiles/number8.png",
    PointType.NINE: "res://assets/tiles/number9.png",
    PointType.TEN: "res://assets/tiles/number10.png",
    PointType.ELEVEN: "res://assets/tiles/number11.png",
    PointType.TWELVE: "res://assets/tiles/number12.png",
}


# 资源映射
enum ResourceType{LUMBER, BRICK, ORE, WOOL, GRAIN}


const TILE_RES = {
    TileType.FIELD: ResourceType.GRAIN,
    TileType.PASTURE: ResourceType.WOOL,
    TileType.FOREST: ResourceType.LUMBER,
    TileType.MOUNTAIN: ResourceType.ORE,
    TileType.HILL: ResourceType.BRICK,
}


const RES_DATA = {
    ResourceType.LUMBER: "res://assets/cards/lumber.png",
    ResourceType.WOOL: "res://assets/cards/wool.png",
    ResourceType.GRAIN: "res://assets/cards/grain.png",
    ResourceType.BRICK: "res://assets/cards/brick.png",
    ResourceType.ORE: "res://assets/cards/ore.png",
}


const RES_ICON_DATA = {
    ResourceType.LUMBER: "res://assets/icons/lumber.png",
    ResourceType.WOOL: "res://assets/icons/wool.png",
    ResourceType.GRAIN: "res://assets/icons/grain.png",
    ResourceType.BRICK: "res://assets/icons/brick.png",
    ResourceType.ORE: "res://assets/icons/ore.png",
}


# 卡牌映射
enum CardType{KNIGHT, VP, ROAD, PLENTY, MONOPOLY}

const DEV_ICON_DATA = "res://assets/icons/development.png"

const CARD_DATA = {
    CardType.KNIGHT: "res://assets/cards/knight.png",
    CardType.VP: "res://assets/cards/vp.png",
    CardType.ROAD: "res://assets/cards/road.png",
    CardType.PLENTY: "res://assets/cards/year.png",
    CardType.MONOPOLY: "res://assets/cards/mono.png",
}


# 建筑映射
enum BuildingType{SETTLEMENT, CITY, ROAD}

const BUILDING_ICON_DATA = {
    BuildingType.SETTLEMENT: "res://assets/icons/settlement.png",
    BuildingType.CITY: "res://assets/icons/city.png",
    BuildingType.ROAD: "res://assets/icons/road.png",
}


# 操作映射
enum OpType{SETTLEMENT, CITY, ROAD, DEV_CARD}


const OP_BTN_DATA = {
    OpType.SETTLEMENT: "res://assets/images/settlement_btn.png",
    OpType.CITY: "res://assets/images/city_btn.png",
    OpType.ROAD: "res://assets/images/road_btn.png",
    OpType.DEV_CARD: "res://assets/images/development_btn.png"
}

const OP_DISABLE_DATA = {
    OpType.SETTLEMENT: "res://assets/images/settlement_btn_disable.png",
    OpType.CITY: "res://assets/images/city_btn_disable.png",
    OpType.ROAD: "res://assets/images/road_btn_disable.png",
    OpType.DEV_CARD: "res://assets/images/development_btn_disable.png"
}

const OP_DATA = {
    OpType.SETTLEMENT: {
        ResourceType.BRICK: 1,
        ResourceType.WOOL: 1,
        ResourceType.LUMBER: 1,
        ResourceType.GRAIN: 1,
    },
    OpType.CITY: {
        ResourceType.GRAIN: 2,
        ResourceType.ORE: 3,
    },
    OpType.ROAD: {
        ResourceType.BRICK: 1,
        ResourceType.LUMBER: 1,
    },
    OpType.DEV_CARD: {
        ResourceType.WOOL: 1,
        ResourceType.ORE: 1,
        ResourceType.GRAIN: 1,
    }
}


# 强盗映射
enum EnemyType{ROBBER, PIRATE}


# 港口映射
enum HarborType{LUMBER, BRICK, ORE, WOOL, GRAIN, GENERIC}


const HARBOR_DATA = {
    HarborType.LUMBER: "res://assets/tiles/lumber_harbor.png",
    HarborType.BRICK: "res://assets/tiles/brick_harbor.png",
    HarborType.ORE: "res://assets/tiles/ore_harbor.png",
    HarborType.WOOL: "res://assets/tiles/wool_harbor.png",
    HarborType.GRAIN: "res://assets/tiles/grain_harbor.png",
    HarborType.GENERIC: "res://assets/tiles/generic_harbor.png",
}


# 数量映射
const NUM_DATA = {
    CatanSize.SMALL: {
        "resource": {
            "total_num": 95,
            "type_num": 5,
            "each_num": {
                ResourceType.BRICK: 19,
                ResourceType.LUMBER: 19,
                ResourceType.ORE: 19,
                ResourceType.WOOL: 19,
                ResourceType.GRAIN: 19,
            },
        },
        "point": {
            "total_num": 18,
            "type_num": 10,
            "each_num": {
                PointType.TWO: 1,
                PointType.THREE: 2,
                PointType.FOUR: 2,
                PointType.FIVE: 2,
                PointType.SIX: 2,
                PointType.EIGHT: 2,
                PointType.NINE: 2,
                PointType.TEN: 2,
                PointType.ELEVEN: 2,
                PointType.TWELVE: 1,
            },
        },
        "card": {
            "total_num": 25,
            "type_num": 5,
            "each_num": {
                CardType.MONOPOLY: 2,
                CardType.ROAD: 2,
                CardType.PLENTY: 2,
                CardType.VP: 5,
                CardType.KNIGHT: 14,
            },
        },
        "building": {
            "total_num": 24,
            "type_num": 3,
            "each_num": {
                BuildingType.SETTLEMENT: 5,
                BuildingType.CITY: 4,
                BuildingType.ROAD: 15,
            },
        },
        "tile": {
            "total_num": 19,
            "type_num": 6,
            "each_num": {
                TileType.DESERT: 1,
                TileType.HILL: 3,
                TileType.MOUNTAIN: 3,
                TileType.PASTURE: 4,
                TileType.FIELD: 4,
                TileType.FOREST: 4,
            },
        },
        "harbor": {
            "total_num": 9,
            "type_num": 6,
            "each_num": {
                HarborType.LUMBER: 1,
                HarborType.BRICK: 1,
                HarborType.ORE: 1,
                HarborType.WOOL: 1,
                HarborType.GRAIN: 1,
                HarborType.GENERIC: 4,
            },
        },
    },
    CatanSize.BIG: {
        "resource": {
            "total_num": 120,
            "type_num": 5,
            "each_num": {
                ResourceType.BRICK: 24,
                ResourceType.LUMBER: 24,
                ResourceType.ORE: 24,
                ResourceType.WOOL: 24,
                ResourceType.GRAIN: 24,
            },
        },
        "point": {
            "total_num": 28,
            "type_num": 10,
            "each_num": {
                PointType.TWO: 2,
                PointType.THREE: 3,
                PointType.FOUR: 3,
                PointType.FIVE: 3,
                PointType.SIX: 3,
                PointType.EIGHT: 3,
                PointType.NINE: 3,
                PointType.TEN: 3,
                PointType.ELEVEN: 3,
                PointType.TWELVE: 2,
            },
        },
        "card": {
            "total_num": 34,
            "type_num": 5,
            "each_num": {
                CardType.MONOPOLY: 3,
                CardType.ROAD: 3,
                CardType.PLENTY: 3,
                CardType.VP: 5,
                CardType.KNIGHT: 20,
            },
        },
        "building": {
            "total_num": 24,
            "type_num": 3,
            "each_num": {
                BuildingType.SETTLEMENT: 5,
                BuildingType.CITY: 4,
                BuildingType.ROAD: 15,
            },
        },
        "tile": {
            "total_num": 30,
            "type_num": 6,
            "each_num": {
                TileType.DESERT: 2,
                TileType.HILL: 5,
                TileType.MOUNTAIN: 5,
                TileType.PASTURE: 6,
                TileType.FIELD: 6,
                TileType.FOREST: 6,
            },
        },
        "harbor": {
            "total_num": 11,
            "type_num": 6,
            "each_num": {
                HarborType.LUMBER: 1,
                HarborType.BRICK: 1,
                HarborType.ORE: 1,
                HarborType.WOOL: 2,
                HarborType.GRAIN: 1,
                HarborType.GENERIC: 5,
            },
        },
    },
}