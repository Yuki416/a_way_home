extends Resource

class_name Spawn_info

@export var time_start:int
@export var time_end:int
@export var enemy:Resource #存放enemy 的tscn
@export var enemy_num:int #enemy number
@export var enemy_spawn_delay:int

var spawn_delay_counter=0
