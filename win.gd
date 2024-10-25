extends Control


func _replay():
	get_tree().change_scene_to_file("res://level.tscn")


func _on_button_button_down():
	get_tree().change_scene_to_file("res://level.tscn")


func _on_button_2_button_down():
	get_tree().quit()
