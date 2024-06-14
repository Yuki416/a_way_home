extends Area2D

var level=1
var hp=9999
var speed = 300.0
var damage=5
var knockback_amount=100
var paths=1 #曲折次數
var attack_size=1.5 #武器大小(範圍)
var attack_speed=4.0 #攻擊間隔

var target=Vector2.ZERO
var target_array=[]

var angle=Vector2.ZERO
var reset_pos=Vector2.ZERO

# sprite javelin regular
var spr_jav_reg=preload("res://a_way_home/survivor template/Textures/Items/Weapons/javelin_3_new.png")
# sprite javelin attack
var spr_jav_atk=preload("res://a_way_home/survivor template/Textures/Items/Weapons/javelin.png")

@onready var player=get_tree().get_first_node_in_group("human_player")
@onready var sprite= $Sprite2D
@onready var collision=$CollisionShape2D
@onready var attackTimer=get_node("%AttackTimer")
@onready var changeDirectionTimer=get_node("%ChangeDirection")
@onready var resetPosTimer=get_node("%ResetPosTimer")
@onready var snd_attack=$snd_attack

signal remove_from_array(object)

func _ready():
	collision.call_deferred("set","disabled",true) #一開始未攻擊先將collision 關閉
	update_javelin()
	_on_reset_pos_timer_timeout()
	
func update_javelin():
	level = player.javelin_level #在human player 中設定 javelin level
	match level:
		1:
			hp=9999
			speed = 250
			damage=10
			knockback_amount=100
			paths=3 #曲折次數
			attack_size=1.5*(1 + player.spell_size) #武器大小(範圍)
			attack_speed=5.0* (1-player.spell_cooldown) #攻擊間隔
		2:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 2
			attack_size=1.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
		3:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 3
			attack_size=1.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
		4:
			hp = 9999
			speed = 200.0
			damage = 15
			knockback_amount = 120
			paths = 3
			attack_size=1.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)		
	scale=Vector2(1.0,1.0)*attack_size
	attackTimer.wait_time=attack_speed
	
func _physics_process(delta):
	if target_array.size()>0:
		position+=angle*speed*delta
	else:
		var player_angle=global_position.direction_to(reset_pos)
		var distance_dif=global_position-player.global_position #distance difference
		var return_speed=20
		if abs(distance_dif.x)>500 or abs(distance_dif.y)>500:
			return_speed=100
		position+=player_angle* return_speed *delta
		rotation=global_position.direction_to(player.global_position).angle() +deg_to_rad(135)

func add_paths():
	snd_attack.play()
	emit_signal("remove_from_array",self) #不要加進hurt_box
	target_array.clear() #先清空目標敵人
	var counter=0
	while counter<paths:
		var new_path=player.get_random_target()
		target_array.append(new_path)
		counter+=1
	enable_attack(true)
	target=target_array[0]
	process_path()

func process_path():
	angle=global_position.direction_to(target)
	print("angle",angle)
	changeDirectionTimer.start()
	var tween =create_tween()
	var new_rotation_degrees=angle.angle()+deg_to_rad(135)
	tween.tween_property(self,"rotation",new_rotation_degrees,0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(atk=true):
	if atk==true:
		collision.call_deferred("set","disabled",false)
		sprite.texture=spr_jav_atk
	else:
		collision.call_deferred("set","disabled",true)
		sprite.texture=spr_jav_reg

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timeout(): #時間到開始尋找新敵人
	if target_array.size()>0:
		target_array.remove_at(0) # 刪掉第一個敵人，選下一個
		
		if target_array.size()>0: #若有下一個敵人可選
			target=target_array[0]
			process_path()
			snd_attack.play()
			emit_signal("remove_from_array",self)
		else: #no more enemy
			enable_attack(false)
			
	else: #no more enemy
		changeDirectionTimer.stop()
		attackTimer.start()
		enable_attack(false)
			
			
			
	


func _on_reset_pos_timer_timeout(): #隨機挑一個方向，讓javelin 生成在player 旁邊
	var choose_direction =randi()%4
	reset_pos=player.global_position
	match choose_direction:
		0:
			reset_pos.x+=50
		1:
			reset_pos.x-=50
		2:
			reset_pos.y+=50
		3:
			reset_pos.y-=50
