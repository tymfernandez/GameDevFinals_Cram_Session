extends Sprite

func _on_Play_pressed():
	get_tree().change_scene("res://Scenes/Pick_Minigames.tscn")

func _on_Exit_pressed():
	get_tree().quit()
