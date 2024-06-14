extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType=0

@onready var collision=$CollisionShape2D
@onready var disableTimer=$DisableTimer

signal hurt(damage,angle,knockback) #自定一個名為 hurt 的信號，帶有參數 damage,angle,knockback

var hit_once_array=[] #紀錄被哪件武器打過

func _on_area_entered(area):
	if area.is_in_group("attack"): #屬於attack group的東西進入area
		if not area.get("damage")==null: #檢查進入區域的東西(pineapple_bomb)是否有 damage 屬性，且其值不為 null
			match  HurtBoxType: #(enemy)計算被打中幾次的方式
				0 : #Cooldown
					collision.call_deferred("set","disabled",true) #讓collision shape 消失
					disableTimer.start() #開始計時
				1 : #HitOnce
					if hit_once_array.has(area)==false: #檢查 hit_once_array 是否已經包含這個 area（即該對象是否已經被擊中過），若否
						hit_once_array.append(area) #將這個 area 加入 hit_once_array
						if area.has_signal("remove_from_array"): 
							if not area.is_connected("remove_from_array",Callable(self,"remove_from_list")): 
								#如果 area 有 remove_from_array 信號，並且還沒有連接到 remove_from_list 方法，則進行連接
								area.connect("remove_from_array",Callable(self,"remove_from_array"))
					else: #如果 hit_once_array 已經包含這個 area，則直接返回，表示這個對象已經被擊中過一次，不再重複計算傷害
						return
				2 : #DisableHitBox
					if area.has_method("tempdisable"): #如果 area 有 tempdisable 方法，則調用該方法
						area.tempdisable()
			var damage=area.damage #獲取 pineapple_bomb 的 damage 值
			# 建立擊退效果
			#---
			var angle=Vector2.ZERO
			var knockback=100 #設定擊退量
			if not area.get("angle") == null: # 檢查進入區域的東西(pineapple_bomb)是否有 angle 屬性，且其值不為 null
				angle=area.angle
			if not area.get("knockback_amount") == null: # 檢查進入區域的東西(pineapple_bomb)是否有 knockback_amount 屬性，且其值不為 null
				knockback=area.knockback_amount
			#---
			emit_signal("hurt",damage,angle,knockback) #當受到攻擊時，程式碼會發出 hurt 信號，通知hit_box受到的傷害值 damage, 
			if area.has_method("enemy_hit"): #當hurt box 偵測到帶有enemy_hit 的func時
				area.enemy_hit(1) #回傳訊號1

func remove_from_list(object): #這個方法用來從 hit_once_array 中移除對象，確保下次可以再次被擊中。這個方法會在 area 發出 remove_from_array 信號時被調用
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false) #重啟 collision shape
