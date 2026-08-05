extends CharacterBody2D

const SPEED = 30.0
const DAMAGE = 1
const STOMP_BOUNCE = -250.0
const MIN_WANDER_TIME = 2.0
const MAX_WANDER_TIME = 4.0
const MIN_HIDDEN_TIME = 1.5
const MAX_HIDDEN_TIME = 3.0

@export var move_direction: float = -1.0

var is_dead = false
var is_hidden = false

func _ready() -> void:
	add_to_group("enemies")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$DetectionArea.body_entered.connect(_on_detection_area_body_entered)
	_play("idle")
	_haunt_loop()


func _physics_process(_delta: float) -> void:
	if is_dead or is_hidden:
		return

	if is_on_wall():
		move_direction *= -1.0

	velocity.x = move_direction * SPEED
	velocity.y = 0
	move_and_slide()

	$AnimatedSprite2D.flip_h = move_direction > 0
	_play("idle")


func _haunt_loop() -> void:
	while not is_dead and is_inside_tree():
		await get_tree().create_timer(randf_range(MIN_WANDER_TIME, MAX_WANDER_TIME)).timeout
		if is_dead or not is_inside_tree():
			return

		await _vanish()
		if is_dead or not is_inside_tree():
			return

		await get_tree().create_timer(randf_range(MIN_HIDDEN_TIME, MAX_HIDDEN_TIME)).timeout
		if is_dead or not is_inside_tree():
			return

		await _reappear()


func _vanish() -> void:
	is_hidden = true
	velocity = Vector2.ZERO
	$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("desappear")
	await $AnimatedSprite2D.animation_finished

	if not is_dead:
		$AnimatedSprite2D.visible = false


func _reappear() -> void:
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("appear")
	await $AnimatedSprite2D.animation_finished

	if is_dead:
		return

	$DetectionArea/CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D.set_deferred("disabled", false)

	is_hidden = false
	_play("idle")


func _play(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		queue_free()


func _on_detection_area_body_entered(body: Node) -> void:
	if is_dead or is_hidden or not body.is_in_group("player"):
		return

	if body.global_position.y < global_position.y - 4.0 and body.velocity.y > 0:
		_die(body)
	else:
		body.take_damage(DAMAGE)


func _die(player: Node) -> void:
	is_dead = true
	velocity = Vector2.ZERO

	$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)

	# Play the player's stomp sound
	if player.has_method("play_stomp_sound"):
		player.play_stomp_sound()

	player.velocity.y = STOMP_BOUNCE

	_play("hit")