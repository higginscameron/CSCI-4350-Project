extends Area2D

func _ready() -> void:
	add_to_group("pineapples")
	PineappleTracker.register_pineapple_spawn()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	PineappleTracker.register_pineapple()
	_collect()


func _collect() -> void:
	set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)

	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property($AnimatedSprite2D, "scale", Vector2(1.4, 1.4), 0.2)
	await tween.finished
	queue_free()
