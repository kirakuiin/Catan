extends Reference


class_name MapLoader


const MAP_FOLDER = "user://map"
const MAP_SUFFIX = ".map"


# 创建地图目录
static func create_map_dir():
    var dir = Directory.new()
    if not dir.dir_exists(MAP_FOLDER):
        dir.make_dir(MAP_FOLDER)


# 保存地图
static func save_map(map_name: String, map_info: Protocol.MapInfo):
    var fp = File.new()
    var file_path = Util.join_file_path([MAP_FOLDER, map_name+MAP_SUFFIX])
    fp.open(file_path, File.WRITE) 
    fp.store_line(to_json(Protocol.serialize(map_info)))
    fp.close()
    Log.logi("存储地图至 %s" % file_path)


# 得到地图列表
static func get_map_list() -> Array:
    var result = []
    var dir = Directory.new()
    if dir.open(MAP_FOLDER) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(MAP_SUFFIX):
                result.append(file_name.trim_suffix(MAP_SUFFIX))
            file_name = dir.get_next()
    return result


# 加载地图
static func get_map(map_name: String) -> Protocol.MapInfo:
    var map_info = Protocol.MapInfo.new()
    var fp = File.new()
    if fp.open(Util.join_file_path([MAP_FOLDER, map_name+MAP_SUFFIX]), File.READ) == OK:
        Log.logd("读取地图[%s]成功".format(map_name))
        var data = parse_json(fp.get_line())
        map_info = Protocol.deserialize(data) as Protocol.MapInfo
        fp.close()
    else:
        Log.logd("读取地图[%s]失败".format(map_name))
    return map_info