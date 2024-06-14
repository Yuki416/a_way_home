extends CharacterBody2D

@export var movement_speed=100.0

@onready var player=get_tree().get_first_node_in_group("human_player")
@onready var anim=get_node("AnimatedSprite2D")

func _physics_process(delta):
	var direction=global_position.direction_to(player.global_position)
	if direction.x>0:
		get_node("AnimatedSprite2D").flip_h=true
	elif direction.x<0:
		get_node("AnimatedSprite2D").flip_h=false
	anim.play("idle")
	velocity=direction*movement_speed
	move_and_slide()
