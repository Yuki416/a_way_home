extends Area2D


var level=1
var hp=1 #設定bomb的生命值，打中敵人就hp minus 1
var speed=100
var damage=5 #攻擊力，減血量
var knockback_amount=100 #该对象的击退量，初始值为100
var attack_size=1.0 #该对象的攻击范围，初始值为1.0

var target=Vector2.ZERO
var angle=Vector2.ZERO

@onready var player=get_tree().get_first_node_in_group("human_player")
signal  remove_from_array(object) #自訂一個信號remove_from_array

@onready var anim=$AnimatedSprite2D

func _ready():
	if not target ==Vector2.ZERO:
		angle=global_position.direction_to(target)
		print("angle:",angle)
		rotation=angle.angle() + deg_to_rad(90) #设置对象的旋转角度，使其面向目标位置，并在此基础上增加 135 度的角度。
	match level:
		1:
			var hp=1
			var speed=100
			var damage=5
			var knockback_amount=100
			var attack_size=1.0 +(1+player.spell_size)
			#player.pineapple_bome_level=1
		2:
			var hp=1
			var speed=100
			var damage=5
			var knockback_amount=100
			var attack_size=1.0 +(1+player.spell_size)
			#player.pineapple_bome_level=2
			#player.pineapple_bomb_baseammo =2
			
	var tween =create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
			
func _physics_process(delta):
	position += angle * speed * delta
	if hp == 1:
		anim.play("fly")
	else:
		anim.play("bomb")
	
func enemy_hit(charge = 1):
	hp -= charge
	#print("pineapple hp", hp)
	#if hp<=0:
		#emit_signal("remove_from_array",self) #發送刪除該bomb的訊號
		#queue_free()
		
func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "bomb":
		queue_free()  # 在 bomb 動畫播放完成後銷毀對象


func _on_timer_timeout():
	emit_signal("remove_from_array",self) #發送刪除該bomb的訊號	
	queue_free()
