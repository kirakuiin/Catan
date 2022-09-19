extends Node2D


# 地点模型


func _ready():
	pass


func set_pos(pos: Vector2):
	position = pos


func set_order(order: int):
	var color = Data.ORDER_DATA[order]
	$SettlementTexture.modulate = color
	$CityTexture.modulate = color


func upgrade_to_city():
	$UpgradeParticle.emitting = true
	yield(get_tree().create_timer(1), "timeout")
	$UpgradeParticle.emitting = false
	$SettlementTexture.hide()
	$CityTexture.show()