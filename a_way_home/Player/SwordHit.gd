extends Area2D

var damage=5
@export var sword_hit_attackspeed=5 #second
var sword_hit_level=1
var sword_hitting=0

func _ready():
	# 未啟動前先將擊劍範圍關閉
	$Sword_hit_collision.disabled=true
