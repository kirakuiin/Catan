extends Control


# 游戏世界


# 初始化世界
func init(order: Protocol.PlayerOrderInfo, setup: Protocol.CatanSetupInfo, map: Protocol.MapInfo):
    $Map/CatanMap.init_with_mapinfo(map)