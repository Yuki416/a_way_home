extends ColorRect

#include upgradeDB
@onready var lblName =$lbl_name
@onready var lblDescription=$lbl_description
@onready var lblLevel=$lbl_level
@onready var itemIcon=$ColorRect/ItemIcon
 
var mouse_over=false
var item=null
@onready var player= get_tree().get_first_node_in_group("human_player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade",Callable(player,"upgrade_character"))
	if item==null:
		item="food"
	lblName.text=UpgradeDb.UPGRADES[item]["displayname"]
	lblDescription.text=UpgradeDb.UPGRADES[item]["details"]
	lblLevel.text=UpgradeDb.UPGRADES[item]["level"]
	itemIcon.texture=load(UpgradeDb.UPGRADES[item]["icon"])
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# pressed
			if mouse_over==true: #如果滑鼠懸停在這個節點上，則執行以下程式碼
				emit_signal("selected_upgrade",item)
				#發射 selected_upgrade 訊號，並傳遞當前的 item 變數作為參數。這會觸發之前連接的 player.upgrade_character 方法
				#get_tree().paused=false

func _on_mouse_entered():
	mouse_over=true

func _on_mouse_exited():
	mouse_over=false
