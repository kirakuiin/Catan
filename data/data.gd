extends Node


class_name Data


# 主机状态
enum HostState {PREPARE, PLAYING}


# 扩展模式
enum ExpansionMode {SETTLER, SEAFARER}


# 玩家数量映射
enum CatanSize {BIG=6, SMALL=4}


# 地块映射
enum TileType{NULL, DESERT, FIELD, HILL, MOUNTAIN, PASTURE, FOREST, OCEAN, GOLD}


# 成就映射
enum AchievementType{ARMY, ROAD}


# 点数映射
enum PointType{ZERO=0, TWO=2, THREE=3, FOUR=4, FIVE=5, SIX=6, SEVEN=7, EIGHT=8, NINE=9, TEN=10, ELEVEN=11, TWELVE=12}


const SMALL_POINT = [PointType.TWO, PointType.TWELVE]
const BIG_POINT = [PointType.SIX, PointType.EIGHT]


# 资源映射
enum ResourceType{LUMBER, BRICK, ORE, WOOL, GRAIN}


const TILE_RES = {
    TileType.FIELD: ResourceType.GRAIN,
    TileType.PASTURE: ResourceType.WOOL,
    TileType.FOREST: ResourceType.LUMBER,
    TileType.MOUNTAIN: ResourceType.ORE,
    TileType.HILL: ResourceType.BRICK,
}


# 卡牌映射
enum CardType{KNIGHT, VP, ROAD, PLENTY, MONOPOLY}


# 建筑映射
enum BuildingType{SETTLEMENT, CITY, ROAD, SHIP}


# 操作映射
enum OpType{SETTLEMENT, CITY, ROAD, DEV_CARD}


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
enum HarborType{NULL, LUMBER, BRICK, ORE, WOOL, GRAIN, GENERIC}

const RES_TO_HARBOR = {
    ResourceType.LUMBER: HarborType.LUMBER,
    ResourceType.WOOL: HarborType.WOOL,
    ResourceType.GRAIN: HarborType.GRAIN,
    ResourceType.BRICK: HarborType.BRICK,
    ResourceType.ORE: HarborType.ORE,
}

const HARBOR_UNIT = {
    HarborType.LUMBER: 2,
    HarborType.BRICK: 2,
    HarborType.ORE: 2,
    HarborType.WOOL: 2,
    HarborType.GRAIN: 2,
    HarborType.GENERIC: 3,
}


# 标准数据
const SETTLER_DATA = {
    CatanSize.SMALL: {
        "vic_point": 10,
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
        "vic_point": 10,
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

# ============================ 航海家数据 ==============================

# 地图枚举
enum SeafarerMap {NEW_SHORE, FOUR_ISLAND, FOG_ISLAND, THROUGH_DESERT, FOGGOTTEN_TRIBE}


# 数量信息
const SEAFARER_DATA = {
    CatanSize.SMALL: {
        SeafarerMap.NEW_SHORE: {
            "vic_point": 13,
            "resource": SETTLER_DATA[CatanSize.SMALL].resource,
            "card":  SETTLER_DATA[CatanSize.SMALL].card,
            "building": SETTLER_DATA[CatanSize.SMALL].building,
            "main_island": {
                "tile": SETTLER_DATA[CatanSize.SMALL].tile,
                "harbor": SETTLER_DATA[CatanSize.SMALL].harbor,
                "point": SETTLER_DATA[CatanSize.SMALL].point,
            },
            "other_islands": {
                "tile": {
                    "total_num": 7,
                    "type_num": 6,
                    "each_num": {
                        TileType.HILL: 1,
                        TileType.MOUNTAIN: 2,
                        TileType.PASTURE: 1,
                        TileType.FIELD: 1,
                        TileType.FOREST: 1,
                        TileType.GOLD: 2,
                    },
                },
                "point": {
                    "total_num": 8,
                    "type_num": 8,
                    "each_num": {
                        PointType.TWO: 1,
                        PointType.THREE: 1,
                        PointType.FOUR: 1,
                        PointType.FIVE: 1,
                        PointType.EIGHT: 1,
                        PointType.NINE: 1,
                        PointType.TEN: 1,
                        PointType.ELEVEN: 1,
                    },
                }
            }
        },
        SeafarerMap.FOUR_ISLAND: {
            "vic_point": 14,
        },
        SeafarerMap.FOG_ISLAND: {
            "vic_point": 15,
        },
        SeafarerMap.THROUGH_DESERT: {
            "vic_point": 16,
        },
        SeafarerMap.FOGGOTTEN_TRIBE: {
            "vic_point": 18,
        },
    },
    CatanSize.BIG: {
        SeafarerMap.NEW_SHORE: {
            "vic_point": 13,
            "resource": SETTLER_DATA[CatanSize.BIG].resource,
            "card":  SETTLER_DATA[CatanSize.BIG].card,
            "building": SETTLER_DATA[CatanSize.BIG].building,
            "main_island": {
                "tile": SETTLER_DATA[CatanSize.BIG].tile,
                "harbor": SETTLER_DATA[CatanSize.BIG].harbor,
                "point": SETTLER_DATA[CatanSize.BIG].point,
            },
            "other_islands": {
                "tile": {
                    "total_num": 10,
                    "type_num": 6,
                    "each_num": {
                        TileType.HILL: 2,
                        TileType.MOUNTAIN: 2,
                        TileType.PASTURE: 1,
                        TileType.FIELD: 1,
                        TileType.FOREST: 1,
                        TileType.GOLD: 3,
                    },
                },
                "point": {
                    "total_num": 10,
                    "type_num": 10,
                    "each_num": {
                        PointType.TWO: 1,
                        PointType.THREE: 1,
                        PointType.FOUR: 1,
                        PointType.FIVE: 1,
                        PointType.SIX: 1,
                        PointType.EIGHT: 1,
                        PointType.NINE: 1,
                        PointType.TEN: 1,
                        PointType.ELEVEN: 1,
                        PointType.TWELVE: 1,
                    },
                }
            }
        },
        SeafarerMap.FOUR_ISLAND: {
            "vic_point": 14,
        },
        SeafarerMap.FOG_ISLAND: {
            "vic_point": 15,
        },
        SeafarerMap.THROUGH_DESERT: {
            "vic_point": 16,
        },
        SeafarerMap.FOGGOTTEN_TRIBE: {
            "vic_point": 18,
        },
    },
}