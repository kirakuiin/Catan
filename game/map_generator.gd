extends Node

# Catan地图生成器

var _setupInfo: Protocol.CatanSetupInfo


# 生成地图
func generate(setup: Protocol.CatanSetupInfo):
    _setupInfo = setup


func _generate_hex_grid():
    match _setupInfo.catan_size:
        Data.CatanSize.BIG:
            _generate_big_grid()
        Data.CatanSize.SMALL:
            _generate_small_grid()


func _generate_small_grid():
    pass


func _generate_big_grid():
    pass