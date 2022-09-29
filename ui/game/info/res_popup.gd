extends PopupPanel


# 资源选择弹窗

const CHOOSE_RES = 2
const CHOOSE_MONO_TYPE = 1


var _res_info: StdLib.Queue


# 弹出资源选择框
func popup_choose_res():
	$Root/Title.text = "请选择两个任意资源"
	_res_info = StdLib.Queue.new(CHOOSE_RES)
	_init_cb()
	popup_centered()


# 弹出垄断选择框
func popup_choose_mono_type():
	$Root/Title.text = "请选择一种垄断的资源类型"
	_res_info = StdLib.Queue.new(CHOOSE_MONO_TYPE)
	_init_cb()
	popup_centered()


func _init_cb():
	for btn in $Root/Btns.get_children():
		btn.set_callback(funcref(self, "_on_click_btn"))


func _on_click_btn(button):
	button.select()
	var poped_btn = _res_info.enqueue(button)
	if poped_btn:
		poped_btn.unselect()


func _on_confirm():
	if _res_info.is_full():
		var result = []
		for btn in _res_info.values():
			result.append(btn.get_type())
		_notify_client_result(result)
		queue_free()
	else:
		$AnimationPlayer.play("show_hint")

func _notify_client_result(result: Array):
	if _res_info.max_len == CHOOSE_MONO_TYPE:
		_get_client().choose_mono_type_done(result[0])
	else:
		_get_client().choose_res_done(_array_to_dict(result))

func _array_to_dict(arr: Array) -> Dictionary:
	var result = {}
	for type in arr:
		Util.dict_add(result, type, 1)
	return result


func _get_client():
	return PlayingNet.get_client()
