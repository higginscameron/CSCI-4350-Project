extends CharacterBody2D

const DAMAGE = 1
const STOMP_BOUNCE = -250.0

## Max distance from the spawn point the bat will wander, left/right and up/down.
@export var horizontal_range: float = 64.0
@export var vertical_range: float = 32.0
@export var speed: float = 40.0
## Brief hover pause after reaching a waypoint before picking a new one.
@export var retarget_pause: float = 0.4

var is_dead = false
var _origin: Vector2
var _target: Vector2
var _is_waiting = false

func _ready() -> void:
	add_to_group("enemies")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$DetectionArea.body_entered.connect(_on_detection_area_body_entered)
	_origin = global_position
	_pick_new_target()
	_play("flying")


func _physics_process(_delta: float) -> void:
	if is_dead or _is_waiting:
		velocity = Vector2.ZERO
		return

	var to_target = _target - global_position
	if to_target.length() <= 2.0:
		_wait_and_retarget()
		return

	velocity = to_target.normalized() * speed
	move_and_slide()
	$AnimatedSprite2D.flip_h = velocity.x < 0
	_play("flying")


func _wait_and_retarget() -> void:
	_is_waiting = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(retarget_pause).timeout
	if is_dead or not is_inside_tree():
		return
	_pick_new_target()
	_is_waiting = false


func _pick_new_target() -> void:
	var offset = Vector2(randf_range(-horizontal_range, horizontal_range), randf_range(-vertical_range, vertical_range))
	_target = _origin + offset


func _play(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		queue_free()


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
