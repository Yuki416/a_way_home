extends Sprite2D

@onready var player=get_tree().get_first_node_in_group("human_player")

# Called when the node enters the scene tree for the first time.
func _ready():
	var direction=global_position.direction_to(player.global_position)
	if direction.x>0:
		get_node("AnimatedSprite2D").flip_h=true
	elif direction.x<0:
		get_node("AnimatedSprite2D").flip_h=false
		
	$AnimatedSprite2D.play("death")







func _on_audio_stream_player_2d_finished():
	queue_free()
