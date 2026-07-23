extends Control

func _ready():
	$Center/Panel/MenuVBox/Start.pressed.connect(_on_Start_pressed)
	$Center/Panel/MenuVBox/Options.pressed.connect(_on_Options_pressed)
	$Center/Panel/MenuVBox/Quit.pressed.connect(_on_Quit_pressed)

func _on_Start_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_Options_pressed():
	print("Options pressed")

func _on_Quit_pressed():
	get_tree().quit()
