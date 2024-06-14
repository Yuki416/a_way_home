extends CharacterBody2D

var movement_speed=150.0
var hp=80
var maxhp=80
@onready var anim=get_node("AnimatedSprite2D")

# exp
var experience=0 # total exp
var experience_level=1 
var collected_experience=0 #吃到exp 瞬間增加的exp 量

#Attacks
var pineapple_bomb=preload("res://a_way_home/Player/Attack/pineapple_bomb.tscn")
var javelin=preload("res://a_way_home/Player/Attack/javelin.tscn")


#AttackNodes
@onready var pineapple_bomb_Timer=get_node("%Pineapple_bomb_Timer")
@onready var pineapple_attack_Timer=get_node("%Pineapple_attack_Timer")
@onready var sword_hit_timer=$AnimatedSprite2D/SwordHit/Sword_hit_timer
@onready var animationPlayer=$AnimationPlayer
@onready var javelinBase=get_node("%JavelinBase")

#Pineapple_bomb
var pineapple_bomb_ammo=0
var pineapple_bomb_baseammo=0
@export var pineapple_bomb_attackspeed=1.5 #設定攻擊間隔
var pineapple_bome_level=0

#Sword Hit
var sword_hit_damage=5
@export var sword_hit_attackspeed=5 #second
var sword_hit_level=1
var sword_hitting=0

#Javelin
var javelin_ammo=1
var javelin_level=0

#Enemy Related
var enemy_close =[] #store enemy that is closing

#GUI
@onready var expBar=$%ExperienceBar
@onready var lbl_level=$%Label_level
@onready var levelPanel=$%LevelUp
@onready var upgradeOptions=$%UpgradeOptions
@onready var itemOptions=preload("res://a_way_home/Utility/item_option.tscn")
@onready var sndLevelUp=$%snd_levelUp

#Up grades
var collected_upgrades=[]
var upgrade_options=[]
var armor=0
var speed=0
var spell_cooldown=0
var spell_size=0
var additional_attacks=0

func _ready():
	anim.play("run")
	attack()
	# 初始化 expBar
	set_expBar(experience,calculate_experienceCap())
	
	#連接Sword_hit_timer 
	sword_hit_timer.connect("timeout",Callable(self,"trigger_sword_hit"))
	

func _physics_process(delta):
	
	movement()

var mov =Vector2.ZERO
var lastMovement
func movement():
	var x_mov =Input.get_axis("ui_left", "ui_right")
	if x_mov==1:
		get_node("AnimatedSprite2D").flip_h=false
	elif x_mov==-1:
		get_node("AnimatedSprite2D").flip_h=true
	var y_mov =Input.get_axis("ui_up", "ui_down")
	mov=Vector2(x_mov,y_mov)
	velocity = mov.normalized()*movement_speed
	move_and_slide()
	
	#print(mov)
	#print("sword hitting: ",sword_hitting)
	# 播放相應的動畫
	if(sword_hitting==0):
		if mov.x > 0 and mov.y==0:
			#anim.flip_h=false
			lastMovement="right"
			anim.play("run")
		elif mov.x < 0 and mov.y==0:
			#anim.flip_h=true
			lastMovement="left"
			anim.play("run")
		elif mov.y > 0:
			lastMovement="down"
			anim.play("down")
		elif mov.y < 0:
			lastMovement="up"
			anim.play("up")
		
	#elif(sword_hitting==1):
		#animationPlayer.play("slash_down")
		
	#else:
		## 如果沒有移動，停止動畫播放器中的動畫
		#anim.play("down")

func attack():
	if pineapple_bome_level>=0:
		pineapple_bomb_Timer.wait_time=pineapple_bomb_attackspeed *(1-spell_cooldown)
		if pineapple_bomb_Timer.is_stopped():
			pineapple_bomb_Timer.start()
	#Sword hit
	if sword_hit_level>0:
		sword_hit_timer.wait_time=sword_hit_attackspeed *(1-spell_cooldown)
		if sword_hit_timer.is_stopped():
			sword_hit_timer.start()
			print("sword_hit_start")
	#javelin
	if javelin_level>0:
		spawn_javelin()

func _on_hurt_box_hurt(damage, _angle, _knockback): # 參數加上 "_" 告訴自己目前沒用到這個參數
	hp-=damage
	print(hp)


func _on_pineapple_bomb_timer_timeout():
	pineapple_bomb_ammo+=pineapple_bomb_baseammo +additional_attacks
	pineapple_attack_Timer.start()


func _on_pineapple_attack_timer_timeout():
	if pineapple_bomb_ammo>0:
		var pineapple_attack=pineapple_bomb.instantiate()
		pineapple_attack.position=position
		pineapple_attack.target=get_random_target()
		pineapple_attack.level=pineapple_bome_level
		add_child(pineapple_attack)
		pineapple_bomb_ammo-=1
		if pineapple_bomb_ammo>0:
			pineapple_attack_Timer.start()
		else:
			pineapple_attack_Timer.stop()

	
		
func get_random_target():
	if enemy_close.size()>0: #enemy appear
		return enemy_close.pick_random().global_position # 回傳位置
	else:
		return Vector2.UP
		
		
		


func _on_enemy_detection_area_body_entered(body): #偵測到敵人
	if not enemy_close.has(body): #list中若無此敵人
		enemy_close.append(body) #把此敵人放進list 

func _on_enemy_detection_area_body_exited(body): #敵人離開偵測區域
	if enemy_close.has(body):
		enemy_close.erase(body)
	


#func _on_sword_hit_area_entered(body):
	#if area.is_in_group("attack"): # 確認進入區域的物件是敵人

func trigger_sword_hit():
	if sword_hit_timer.timeout:
		sword_hit_timer.start()
		#print("sword_hit_start")
		sword_hitting=1
		if lastMovement=="right": 
			animationPlayer.play("slash_right")
		elif lastMovement=="left":
			animationPlayer.play("slash_left")
		elif lastMovement=="up": #up
			animationPlayer.play("slash_up")
		elif lastMovement=="down":
			animationPlayer.play("slash_down")
		await animationPlayer.animation_finished
		sword_hitting=0
		

#func _on_sword_hit_timer_timeout():
	#sword_hit_timer.start()

func spawn_javelin():
	var get_javelin_total=javelinBase.get_child_count()
	var calc_spawns=(javelin_ammo+additional_attacks) -get_javelin_total #計算需要生成多少javelin
	while calc_spawns>0:
		var javelin_spawn=javelin.instantiate()
		javelin_spawn.global_position=global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns-=1
	
	#upgrade javelin
	var get_javelins=javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("upgrade_javelin"):
			i.upgrade_javelin()

# get exp
func _on_grab_area_area_entered(area):
	var nodes = get_tree().get_nodes_in_group("loot")
	var first_node = nodes[0]        
	print("First node in group " + "loot" + " is: " + first_node.name)  #first node 是 Loot
	if area.is_in_group("loot"):
		area.target=self # exp 的target 為 human_player
	
func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var exp=area.collect()
		calculate_experience(exp)
			
func calculate_experience(exp):
	var exp_required=calculate_experienceCap()
	collected_experience+= exp #吃到exp 當下獲得的exp
	print("exp_get ",collected_experience)
	if experience + collected_experience >= exp_required:
		collected_experience -= (exp_required - experience) #升等，減去需要的exp 加上原有的exp
		experience_level+=1
		lbl_level.text=str("Level :",experience_level)
		print(experience_level)
		experience=0
		exp_required=calculate_experienceCap() #算下次升等所需exp
		#level up
		levelUp()
		
		calculate_experience(0) #重新計算是否有剩餘exp 足夠升等
		
	else:
		experience+=collected_experience
		collected_experience=0 #clear
		
	# 計算完剩餘exp後 更新expBar
	set_expBar(experience,exp_required)
	
	
	
func calculate_experienceCap(): # exp cap =exp capacity 上限
	var exp_cap :int
	if experience_level<=20:
		exp_cap=experience_level*5 #上限一次加5
	elif experience_level<=40:
		exp_cap= 95+ (experience_level-19)*8 #上限一次加8
	else:
		exp_cap= 255 +(experience_level-39)*12
	
	return exp_cap
	
func set_expBar(set_value=1, set_max_value=100):
	expBar.value=set_value # 更新當前total exp
	expBar.max_value=set_max_value # 更新當前 level 的最大exp
	
func levelUp():
	sndLevelUp.play()
	lbl_level.text=str("Level :",experience_level)
	var tween=levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(376,74),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# panel 移動時間0.2 second
	tween.play()
	levelPanel.visible=true
	
	# spawn options in GUI
	var options=0
	var optionsMax=3
	while options < optionsMax:
		var option_choice=itemOptions.instantiate()
		option_choice.item=get_random_item()
		upgradeOptions.add_child(option_choice)
		options+=1
	print("options ",options)
	#---
	get_tree().paused=true
	
func upgrade_character(upgrade): #mouse click之後
	match upgrade:
		"pineapple1":
			pineapple_bome_level = 1
			pineapple_bomb_baseammo += 1
			print("here")
		"pineapple2":
			pineapple_bome_level = 2
			pineapple_bomb_baseammo += 1
		"pineapple3":
			pineapple_bome_level = 3
		"pineapple4":
			pineapple_bome_level = 4
			pineapple_bomb_baseammo += 2
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
			
	attack()
	var option_children=upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible=false
	levelPanel.position=Vector2(1276,74)
	get_tree().paused=false
	
func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #Find already collected upgrades
			pass
		elif i in upgrade_options: #If the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #Don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #Check for PreRequisites
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null
	
	
