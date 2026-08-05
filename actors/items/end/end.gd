extends Area2D

@export var hint_message: String = "Collect all pineapples and rescue your friends first!"

var is_complete = false
var _hint_tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if is_complete or not body.is_in_group("player"):
		return

	if PineappleTracker.all_collected() and RescueTracker.all_rescued():
		_complete_level()
	else:
		_show_hint()


func _complete_level() -> void:
	is_complete = true
	$AnimatedSprite2D.play("raise")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("flag_idle")

	var overlay = preload("res://scenes/level_complete.gd").new()
	get_tree().root.add_child(overlay)
	get_tree().paused = true


func _show_hint() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()

	$HintLabel.text = hint_message
	$HintLabel.visible = true
	$HintLabel.modulate.a = 1.0

	_hint_tween = create_tween()
	_hint_tween.tween_interval(1.5)
	_hint_tween.tween_property($HintLabel, "modulate:a", 0.0, 0.5)
	_hint_tween.tween_callback(func(): $HintLabel.visible = false)
