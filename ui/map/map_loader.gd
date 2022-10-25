extends Reference


class_name MapLoader


const BUILTIN = {
    Data.ExpansionMode.SETTLER: MapData.STD_DATA,
    Data.ExpansionMode.SEAFARER: MapData.SEA_DATA
}

const SUFFIX = {
    Data.ExpansionMode.SETTLER: ".stdmap",
    Data.ExpansionMode.SEAFARER: ".seamap",
}

const MAP_FOLDER = "user://map"


# 创建地图目录
static func create_map_dir():
    var dir = Directory.new()
    if not dir.dir_exists(MAP_FOLDER):
        dir.make_dir(MAP_FOLDER)


# 保存地图
static func save_map(map_name: String, map_info: Protocol.MapInfo, mode: int=Data.ExpansionMode.SETTLER):
    var fp = File.new()
    var file_path = get_map_path(map_name, mode)
    fp.open(file_path, File.WRITE) 
    fp.store_line(to_json(Protocol.str_serialize(map_info)))
    fp.close()
    Log.logi("存储地图至 %s" % file_path)


# 获得地图路径
static func get_map_path(map_name: String, mode: int=Data.ExpansionMode.SETTLER) -> String:
    return Util.join_file_path([MAP_FOLDER, map_name+get_suffix(mode)])


# 获得地图后缀
static func get_suffix(mode: int=Data.ExpansionMode.SETTLER) -> String:
    return SUFFIX[mode]


# 获得全部地图
static func get_map_list(mode: int=Data.ExpansionMode.SETTLER) -> Array:
    return get_builtin(mode) + get_custom(mode)


# 得到地图列表
static func get_custom(mode: int=Data.ExpansionMode.SETTLER) -> Array:
    var result = []
    var dir = Directory.new()
    if dir.open(MAP_FOLDER) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        var suffix = get_suffix(mode)
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(suffix):
                result.append(file_name.trim_suffix(suffix))
            file_name = dir.get_next()
    return result


# 获得内建地图
static func get_builtin(mode: int=Data.ExpansionMode.SETTLER) -> Array:
    return BUILTIN[mode].keys()


# 加载地图
static func get_map(map_name: String, mode: int=Data.ExpansionMode.SETTLER) -> Protocol.MapInfo:
    var data = null
    var result = FAILED
    if map_name in get_builtin(mode):
        Log.logd("读取内建地图")
        data = BUILTIN[mode][map_name]
        result = OK
    else:
        var fp = File.new()
        result = fp.open(get_map_path(map_name, mode), File.READ)
        data = parse_json(fp.get_line())
        fp.close()
    if result == OK:
        Log.logd("读取地图[%s]成功" % map_name)
        return Protocol.str_deserialize(data) as Protocol.MapInfo
    else:
        Log.logd("读取地图[%s]失败" % map_name)
        return null


# 是否存在地图
static func has_map(map_name: String, mode: int=Data.ExpansionMode.SETTLER) -> bool:
    var fp = File.new()
    return map_name in get_builtin() or fp.file_exists(get_map_path(map_name, mode))


# 删除地图
static func remove_map(map_name: String, mode: int=Data.ExpansionMode.SETTLER):
    Directory.new().remove(get_map_path(map_name, mode))