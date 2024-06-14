extends Node2D


@export var spawns: Array[Spawn_info]=[] # create spawns array( list)
# creates an exported variable spawns, which is an array of Spawn_info objects

var player :Node = null


var time=0

func _ready():
	player = get_tree().get_first_node_in_group("human_player")
	print("hello")

func _on_timer_timeout():
	#print(time)
	time+=1
	var enemy_spawns =spawns # Creates a local variable enemy_spawns and sets it to the spawns list
	for i in enemy_spawns:
		if time>= i.time_start and time<= i.time_end:
			if i.spawn_delay_counter<i.enemy_spawn_delay:
				#print(i.enemy_spawn_delay)
				i.spawn_delay_counter+=1
			else:
				i.spawn_delay_counter=0
				var new_enemy=i.enemy
				#print(str(i.enemy.resource_path))
				var counter=0
				while counter <i.enemy_num:
					var enemy_spawn=new_enemy.instantiate()
					enemy_spawn.global_position=get_random_position()
					add_child(enemy_spawn) # add child node to world
					counter+=1
		


func get_random_position():
	var vpr= get_viewport_rect().size*randf_range(2,2.5)
	#var vpr= get_viewport_rect().size
	print(vpr)
	var top_left= Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right= Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left= Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right= Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	
	var pos_side=["up","down","right","left"].pick_random() 
	#從 "up", "down", "right", "left" 四個方向中隨機選擇一個作為生成位置的邊
	
	var spawn_pos1=Vector2.ZERO
	var spawn_pos2=Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1=top_left
			spawn_pos2=top_right
		"down":
			spawn_pos1=bottom_left
			spawn_pos2=bottom_right
		"right":
			spawn_pos1=top_right
			spawn_pos2=bottom_right
		"left":
			spawn_pos1=top_left
			spawn_pos2=bottom_left
	
	var x_spawn= randf_range(spawn_pos1.x,spawn_pos2.x)
	var y_spawn= randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)
	
	
	
	
	
	
	

