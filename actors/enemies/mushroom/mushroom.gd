extends CharacterBody2D

const SPEED = 40.0
const GRAVITY = 980.0
const DAMAGE = 1
const STOMP_BOUNCE = -250.0
const HAZARD_CHECK_DISTANCE = 14.0

@export var move_direction: float = -1.0

var is_dead = false

func _ready() -> void:
	add_to_group("enemies")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$DetectionArea.body_entered.connect(_on_detection_area_body_entered)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	$HazardCheck.target_position.x = HAZARD_CHECK_DISTANCE * move_direction
	$HazardCheck.force_raycast_update()

	if is_on_wall() or _hazard_ahead():
		move_direction *= -1.0

	velocity.x = move_direction * SPEED
	move_and_slide()

	$AnimatedSprite2D.flip_h = move_direction > 0
	_play("run")


func _hazard_ahead() -> bool:
	if not $HazardCheck.is_colliding():
		return false
	var collider = $HazardCheck.get_collider()
	return collider != null and collider.is_in_group("hazards")


func _play(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func _on_detection_area_body_entered(body: Node) -> void:
	if is_dead or not body.is_in_group("player"):
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
	player.velocity.y = STOMP_BOUNCE
	_play("hit")


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		queue_free()
