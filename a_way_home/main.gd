extends Node2D


func _ready():
	Bgm.stream_paused = true


func _on_play_pressed():
	get_tree().change_scene_to_file("res://a_way_home/World.tscn")



func _on_quit_pressed():
	#get_tree().quit()
	pass
