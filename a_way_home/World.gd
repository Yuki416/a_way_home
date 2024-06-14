extends Node2D

@onready var end_game=$end_game
@onready var audio=$AudioStreamPlayer
@onready var sprite=$Sprite2D
@onready var player=get_tree().get_first_node_in_group("human_player")
@onready var snd=$AudioStreamPlayer2

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.visible=false
	Bgm.stream_paused=true
	audio.play()
	snd.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Bgm.stream_paused=true
	if Input.is_action_just_pressed("p") :
		audio.stream_paused=true
		player.visible=false
		sprite.global_position=player.global_position
		sprite.visible=true
		end_game.play()
		await end_game.finished
		Bgm.stream_paused=false
		RpgManager.change_scene_and_tp("corridor","Exit001")
