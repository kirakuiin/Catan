extends Node


class_name Data


# 主机状态
enum HostState {PREPARE, PLAYING}


# 扩展模式
enum ExpansionMode {SETTLER, SEAFARER}


# 玩家数量映射
enum CatanSize {BIG=6, SMALL=4}


# 地块映射
enum TileType{NULL, DESERT, FIELD, HILL, MOUNTAIN, PASTURE, FOREST, OCEAN, GOLD, RANDOM}


# 规则映射
enum RuleType{NULL, SEAFARER, SPECIAL_BUILD, FIXED_START, EXPLORE, COLONIZE}


# 特殊地形映射
enum LandformType{NULL, SETTLEMENT=1, CLOUD=2} # 这里采用2的幂的形式来表示


# 是否为有效地块
static func is_valid_tile(tile_type: int) -> bool:
    return not tile_type in [TileType.NULL]


# 是否为无点地块
static func is_no_point_tile(tile_type: int) -> bool:
    return tile_type in [TileType.OCEAN, TileType.DESERT]


# 是否为资源地块
static func is_res_tile(tile_type: int) -> bool:
    return not is_no_point_tile(tile_type)


# 成就映射
enum AchievementType{ARMY, ROAD}


# 点数映射
enum PointType{ZERO=0, TWO=2, THREE=3, FOUR=4, FIVE=5, SIX=6, SEVEN=7, EIGHT=8, NINE=9, TEN=10, ELEVEN=11, TWELVE=12, RANDOM=13}


# 是否为有效点数
static func is_valid_point(point_type: int) -> bool:
    return not point_type in [PointType.ZERO]

# 是否为大点
static func is_big_point(point_type: int) -> bool:
    return point_type in [PointType.SIX, PointType.EIGHT]

# 是否为小点
static func is_small_point(point_type: int) -> bool:
    return point_type in [PointType.TWO, PointType.TWELVE]


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
enum HarborType{NULL, LUMBER, BRICK, ORE, WOOL, GRAIN, GENERIC, RANDOM}

# 是否为有效港口
static func is_valid_harbor(harbor_type: int) -> bool:
    return not harbor_type in [HarborType.NULL]


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
    "vic_point": 10,
    "resource": {
        ResourceType.BRICK: 19,
        ResourceType.LUMBER: 19,
        ResourceType.ORE: 19,
        ResourceType.WOOL: 19,
        ResourceType.GRAIN: 19,
    },
    "point": {
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
    "card": {
        CardType.MONOPOLY: 2,
        CardType.ROAD: 2,
        CardType.PLENTY: 2,
        CardType.VP: 5,
        CardType.KNIGHT: 14,
    },
    "building": {
        BuildingType.SETTLEMENT: 5,
        BuildingType.CITY: 4,
        BuildingType.ROAD: 15,
    },
    "tile": {
        TileType.DESERT: 1,
        TileType.HILL: 3,
        TileType.MOUNTAIN: 3,
        TileType.PASTURE: 4,
        TileType.FIELD: 4,
        TileType.FOREST: 4,
    },
    "harbor": {
        HarborType.LUMBER: 1,
        HarborType.BRICK: 1,
        HarborType.ORE: 1,
        HarborType.WOOL: 1,
        HarborType.GRAIN: 1,
        HarborType.GENERIC: 4,
    },
}


static func get_resource_data():
    return SETTLER_DATA.resource.duplicate()


static func get_card_data():
    return SETTLER_DATA.card.duplicate()


static func get_building_data():
    return SETTLER_DATA.building.duplicate()


static func get_tile_pool():
    return SETTLER_DATA.tile.duplicate()


static func get_point_pool():
    return SETTLER_DATA.point.duplicate()


static func get_harbor_pool():
    return SETTLER_DATA.harbor.duplicate()


static func get_vp():
    return SETTLER_DATA.vic_point


# ============================ 航海家数据 ==============================

# 地图枚举
enum SeafarerMap {NEW_SHORE, FOUR_ISLAND, FOG_ISLAND, THROUGH_DESERT, FOGGOTTEN_TRIBE}