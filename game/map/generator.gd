extends Node


# Catan地图生成器

const Settler: Script = preload("res://game/map/settler.gd")
const SeaFarer: Script = preload("res://game/map/seafarer.gd")


# 生成地图
func generate(setup: Protocol.CatanSetupInfo, map_info: Protocol.MapInfo):
    var generator = null
    if setup.is_settler():
        generator = Settler.new(setup, map_info)
    elif setup.is_seafarer():
        generator = SeaFarer.new(setup, map_info)
    if generator:
        generator.generate()