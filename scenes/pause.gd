extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var pause_music: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	if pause_music == null:
		push_error("PauseMusic has not been assigned in the Inspector.")
		return

	pause_music.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_music.stop()


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

	if pause_music != null:
		pause_music.play()

	anim.play("pause_in")


func hide_pause_menu() -> void:
	if pause_music != null:
		pause_music.stop()

	anim.play_backwards("pause_in")
	await anim.animation_finished

	visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	hide_pause_menu()


func _on_quit_pressed() -> void:
	if pause_music != null:
		pause_music.stop()

	get_tree().paused = false
	get_tree().quit()


func _on_restart_pressed() -> void:
	#DeathTracker.reset()
	if pause_music != null:
		pause_music.stop()

	get_tree().paused = false
	get_tree().reload_current_scene()
