extends Node


class_name Data


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


# 卡牌映射
enum CardType{KNIGHT, VP, ROAD, PLENTY, MONOPOLY}


# 成就映射
enum AchievementType{ARMY, ROAD}


# 点数映射
enum PointType{TWO, THREE, FOUR, FIVE, SIX, EIGHT, NINE, TEN, ELEVEN, TWELVE}


# 建筑映射
enum BuildingType{SETTLEMENT, CITY, ROAD}


# 资源映射
enum ResourceType{WOOD, BRICK, ROCK, SHEEP, WHEAT}


# 强盗映射
enum EnemyType{ROBBER, PIRATE}


# 港口映射
enum HarborType{WOOD, BRICK, ROCK, SHEEP, WHEAT, GENERIC}


# 数量映射
const NUM_DATA = {
    CatanSize.SMALL: {
        "resource": {
            "total_num": 95,
            "type_num": 5,
            ResourceType.BRICK: 19,
            ResourceType.WOOD: 19,
            ResourceType.ROCK: 19,
            ResourceType.SHEEP: 19,
            ResourceType.WHEAT: 19,
        },
        "point": {
            "total_num": 18,
            "type_num": 10,
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
            "total_num": 25,
            "type_num": 5,
            CardType.MONOPOLY: 2,
            CardType.ROAD: 2,
            CardType.PLENTY: 2,
            CardType.VP: 5,
            CardType.KNIGHT: 14,
        },
        "building": {
            "total_num": 24,
            "type_num": 3,
            BuildingType.SETTLEMENT: 5,
            BuildingType.CITY: 4,
            BuildingType.ROAD: 15,
        },
        "tile": {
            "total_num": 37,
            "type_num": 7,
            "min_num": 3,
            TileType.DESERT: 1,
            TileType.OCEAN: 18,
            TileType.HILL: 3,
            TileType.MOUNTAIN: 3,
            TileType.PASTURE: 4,
            TileType.FIELD: 4,
            TileType.FOREST: 4,
        },
        "harbor": {
            "total_num": 9,
            "type_num": 6,
            HarborType.WOOD: 1,
            HarborType.BRICK: 1,
            HarborType.ROCK: 1,
            HarborType.SHEEP: 1,
            HarborType.WHEAT: 1,
            HarborType.GENERIC: 1,
        },
    },
}