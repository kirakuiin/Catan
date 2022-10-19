extends Reference


class_name MapLoader


const MAP_FOLDER = "user://map"
const STD_SUFFIX = ".stdmap"
const SEA_SUFFIX = ".seamap"


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
    var suffix = STD_SUFFIX
    match mode:
        Data.ExpansionMode.SEAFARER:
            suffix = SEA_SUFFIX
    return suffix


# 得到地图列表
static func get_map_list(mode: int=Data.ExpansionMode.SETTLER) -> Array:
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


# 加载地图
static func get_map(map_name: String, mode: int=Data.ExpansionMode.SETTLER) -> Protocol.MapInfo:
    var map_info = Protocol.MapInfo.new()
    var fp = File.new()
    if fp.open(get_map_path(map_name, mode), File.READ) == OK:
        Log.logd("读取地图[%s]成功" % map_name)
        var data = parse_json(fp.get_line())
        map_info = Protocol.str_deserialize(data) as Protocol.MapInfo
        fp.close()
    else:
        Log.logd("读取地图[%s]失败" % map_name)
    return map_info


# 是否存在地图
static func has_map(map_name: String, mode: int=Data.ExpansionMode.SETTLER) -> bool:
    var fp = File.new()
    return fp.file_exists(get_map_path(map_name, mode))