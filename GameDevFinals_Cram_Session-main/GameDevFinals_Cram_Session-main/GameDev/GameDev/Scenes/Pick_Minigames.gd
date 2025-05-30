extends Sprite

func _on_Goto_quicknotes_pressed():
	get_tree().change_scene("res://Scenes/QuickNotes.tscn")


func _on_Goto_papertoss_pressed():
	get_tree().change_scene("res://Scenes/PaperToss.tscn")


func _on_Back_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")


func _on_Next_pressed():
		get_tree().change_scene("res://Scenes/Pick_Minigames2.tscn")
