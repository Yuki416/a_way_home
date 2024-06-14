extends Area2D

@export var exp=20 #設定物件的經驗值量

var sprite_blue=preload("res://a_way_home/Objects/exp.png")
var sprite_red=preload("res://a_way_home/Objects/exp_red.png")

var target=null
var speed=-2 #-1 讓exp 的動畫看起來有反彈特效

@onready var sprite=$Sprite2D
@onready var collision=$CollisionShape2D
@onready var sound=$snd_collected

func _ready():
	if exp < 10: #blue
		return
	else: # red
		sprite.texture=sprite_red
		
func _physics_process(delta):
	if target!=null:
		global_position=global_position.move_toward(target.global_position,speed)
		speed+=2*delta

func collect():
	sound.play()
	collision.call_deferred("set","disable",true)
	#延遲禁用碰撞檢測，確保音效播放完畢後再進行禁用操作
	sprite.visible=false
	return exp	


func _on_snd_collected_finished():
	queue_free()
