extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		show_pause_menu()
	else:
		hide_pause_menu()

func show_pause_menu() -> void:
	visible = true
	anim.play("pause_in")

func hide_pause_menu() -> void:
	anim.play_backwards("pause_in")
	await anim.animation_finished
	visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	hide_pause_menu()


func _on_quit_pressed() -> void:
	get_tree().quit()
