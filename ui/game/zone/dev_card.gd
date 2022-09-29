extends Node2D


# 开发卡

const UP := Vector2(0, -180)
const SCALE := Vector2(1.6, 1.6)
const ORI_SCALE := Vector2(1, 1)


class NormalState:
	extends StdLib.SimpleState

	func _to_string():
		return "NormalState"


class ZoomState:
	extends StdLib.SimpleState

	var _card_ref: WeakRef

	func _init(card):
		_card_ref = weakref(card)

	func _to_string():
		return "ZoomState"

	func enter():
		_card_ref.get_ref().zoom_in()

	func exit():
		_card_ref.get_ref().zoom_out()


class DragState:
	extends StdLib.SimpleState

	var _card_ref: WeakRef

	func _init(card):
		_card_ref = weakref(card)

	func _to_string():
		return "DragState"

	func enter():
		_card_ref.get_ref().zoom_in()

	func exit():
		_card_ref.get_ref().zoom_out()


var origin_pos: Vector2


var _type: int

var _state: StdLib.SimpleState
var _normal: NormalState
var _zoom: ZoomState 
var _drag: DragState


func _ready():
	$DragArea.set_enable_rect(get_rect())
	_normal = NormalState.new()
	_zoom = ZoomState.new(self)
	_drag = DragState.new(self)
	_state = _normal


# 设置卡牌类型
func set_type(dev_type: int):
	_type = dev_type
	$CardImage.texture = ResourceLoader.load(Data.CARD_DATA[dev_type])


# 获得类型
func get_type() -> int:
	return _type


# 设置高度
func set_height(height: float):
	var ratio = $CardImage.rect_min_size.x/$CardImage.rect_min_size.y
	$CardImage.rect_size.y = height
	$CardImage.rect_size.x = ratio*height
	$DragArea.set_enable_rect(get_rect())
	_update_collision()

func _update_collision():
	$CardImage/Area.position = $CardImage.rect_size/2
	$CardImage/Area/Collision.shape.extents = $CardImage.rect_size/2


# 获得宽度
func get_width() -> float:
	return $CardImage.rect_size.x


# 设置数量
func set_num(num: int):
	$CardImage/Num.text = "x%d" % num


# 得到数量
func get_num() -> int:
	return int($CardImage/Num.text.right(1))


# 通知位置重排
func notify_change_pos(pos: Vector2):
	if _state is NormalState:
		position = pos
	else:
		origin_pos = pos


# 放大
func zoom_in():
	save_pos()
	position += UP
	position.x -= $CardImage.rect_size.x*(SCALE.x-1)/2
	scale = SCALE
	var rect = get_rect()
	rect.size *= SCALE
	$DragArea.set_enable_rect(rect)


# 缩小
func zoom_out():
	scale = ORI_SCALE
	reset_pos()


# 还原位置
func reset_pos():
	position = origin_pos
	$DragArea.set_enable_rect(get_rect())


# 记忆位置
func save_pos():
	origin_pos = position


# 获得包围盒
func get_rect() -> Rect2:
	var origin := position
	if get_parent() is CanvasItem:
		origin = get_parent().get_global_transform()*position
	return Rect2(origin, $CardImage.rect_size)
	

func _on_mouse_entered():
	if _state is NormalState:
		_state = _state.to_state(_zoom)


func _on_mouse_exited():
	if _state is ZoomState:
		_state = _state.to_state(_normal)


func _on_drag_card(relative):
	if _state is DragState:
		position += relative


func _on_drag_started(pos):
	if _state is ZoomState and _check_can_play_card():
		_state = _state.to_state(_drag)


func _check_can_play_card() -> bool:
	if _type == Data.CardType.VP:
		return false
	elif not _get_client().client_state in [NetDefines.ClientState.FREE_ACTION, NetDefines.ClientState.PLAY_BEFORE_DICE]:
		return false
	elif _get_client().client_state == NetDefines.ClientState.PLAY_BEFORE_DICE and _type != Data.CardType.KNIGHT:
		_get_client().show_hint("此阶段只能打出骑士卡!")
		return false
	elif _get_client().personal_info.is_played_card:
		_get_client().show_hint("每回合只能打出一张牌!")
		return false
	else:
		return true


func _on_drag_ended(pos):
	if _state is DragState:
		_state = _state.to_state(_normal)
		if _check_is_playing():
			get_parent().play_card(_type)

func _check_is_playing():
	return not get_parent().get_area().overlaps_area($CardImage/Area)


func _get_client():
	return PlayingNet.get_client()
