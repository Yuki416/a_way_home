extends CharacterBody2D

var movement_speed=200.0
@onready var anim=get_node("AnimatedSprite2D")

func _physics_process(delta):
	movement()
	
func movement():
	var x_mov = Input.get_axis("ui_left", "ui_right")
	if x_mov==1:
		get_node("AnimatedSprite2D").flip_h=false
	elif x_mov==-1:
		get_node("AnimatedSprite2D").flip_h=true
	var y_mov =Input.get_axis("ui_up", "ui_down")
	var mov=Vector2(x_mov,y_mov)
	velocity = mov.normalized()*movement_speed
	move_and_slide()
	
	print(mov)
	# 播放相應的動畫
	if mov.x > 0 and mov.y==0:
		#anim.flip_h=false
		anim.play("run")
	elif mov.x < 0 and mov.y==0:
		#anim.flip_h=true
		anim.play("run")
	elif mov.y > 0:
		anim.play("down")
	elif mov.y < 0:
		anim.play("up")
	#else:
		## 如果沒有移動，停止動畫播放器中的動畫
		#anim.play("down")
