extends Area2D

const DAMAGE = 1

## Keep the fire burning permanently. When false, it cycles on/off using the timers below.
@export var always_on: bool = true
@export var start_on: bool = true
@export var on_duration: float = 1.5
@export var off_duration: float = 1.5

var is_on: bool = true

func _ready() -> void:
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

	if always_on:
		_set_state(true, false)
	else:
		_set_state(start_on, false)
		_cycle_loop()


func _cycle_loop() -> void:
	while not always_on and is_inside_tree():
		await get_tree().create_timer(on_duration if is_on else off_duration).timeout
		if not is_inside_tree():
			return
		_set_state(not is_on, true)


func _set_state(turning_on: bool, animate_ignite: bool) -> void:
	is_on = turning_on
	$CollisionShape2D.set_deferred("disabled", not is_on)

	if not is_on:
		$AnimatedSprite2D.play("off")
		return

	if animate_ignite:
		$AnimatedSprite2D.play("hit")
	else:
		$AnimatedSprite2D.play("on")

	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(DAMAGE)


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit" and is_on:
		$AnimatedSprite2D.play("on")


func _on_body_entered(body: Node) -> void:
	if is_on and body.is_in_group("player"):
		body.take_damage(DAMAGE)
