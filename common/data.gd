extends Node

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
enum TileType{DESERT, OCEAN, FIELD, HILL, MOUNTAIN, PASTURE, FOREST}

const TILE_DATA = {
    TileType.DESERT: "res://assets/tiles/desert.png",
    TileType.OCEAN: "res://assets/tiles/ocean.png",
    TileType.FIELD: "res://assets/tiles/field.png",
    TileType.HILL: "res://assets/tiles/hill.png",
    TileType.MOUNTAIN: "res://assets/tiles/mountain.png",
    TileType.PASTURE: "res://assets/tiles/pasture.png",
    TileType.FOREST: "res://assets/tiles/forest.png",
}