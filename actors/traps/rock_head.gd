extends CharacterBody2D

## Shared logic for the Rock Head and Spike Head traps: patrol left/right, and
## slam straight down when the player walks into the column below, then rise
## back to the patrol height. Spike Head reuses this script with faster
## speeds and a lethal damage value.

enum State { PATROL, ALERT, DROPPING, LANDED, RISING, TOP_LANDED }

@export var patrol_speed: float = 30.0
## How far the head travels left/right from its start position before turning
## around on its own. Set to 0 to only turn around when it hits a wall.
@export var patrol_distance: float = 80.0
@export var drop_speed: float = 260.0
@export var rise_speed: float = 90.0
@export var detection_range: float = 500.0
@export var alert_delay: float = 0.35
@export var landed_pause: float = 0.4
@export var top_pause: float = 0.2
@export var damage: int = 1

var move_direction: float = -1.0
var state: State = State.PATROL
var _origin_x: float
var _origin_y: float

func _ready() -> void:
	add_to_group("hazards")
	$HurtArea.body_entered.connect(_on_hurt_area_body_entered)
	_origin_x = global_position.x
	_origin_y = global_position.y
	_play("blink")


func _physics_process(delta: float) -> void:
	match state:
		State.PATROL:
			_patrol()
		State.DROPPING:
			_drop()
		State.RISING:
			_rise()
		_:
			pass


func _patrol() -> void:
	$DropCheck.target_position = Vector2(0, detection_range)
	$DropCheck.force_raycast_update()
	if $DropCheck.is_colliding() and $DropCheck.get_collider().is_in_group("player"):
		_start_alert()
		return

	var hit_wall = is_on_wall()
	var reached_patrol_limit = patrol_distance > 0.0 and absf(global_position.x - _origin_x) >= patrol_distance

	if hit_wall or reached_patrol_limit:
		var hit_left = move_direction < 0
		move_direction *= -1.0
		if hit_wall:
			$AnimatedSprite2D.play("left_hit" if hit_left else "right_hit")

	velocity = Vector2(move_direction * patrol_speed, 0)
	move_and_slide()
	$AnimatedSprite2D.flip_h = move_direction > 0
	_play("blink")


func _start_alert() -> void:
	state = State.ALERT
	velocity = Vector2.ZERO
	await get_tree().create_timer(alert_delay).timeout
	if not is_inside_tree():
		return
	state = State.DROPPING


func _drop() -> void:
	velocity = Vector2(0, drop_speed)
	move_and_slide()
	if is_on_floor():
		_land()


func _land() -> void:
	state = State.LANDED
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("bottom_hit")
	await get_tree().create_timer(landed_pause).timeout
	if not is_inside_tree():
		return
	state = State.RISING


func _rise() -> void:
	velocity = Vector2(0, -rise_speed)
	move_and_slide()
	if global_position.y <= _origin_y:
		global_position.y = _origin_y
		_finish_rise()


func _finish_rise() -> void:
	state = State.TOP_LANDED
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("top_hit")
	await get_tree().create_timer(top_pause).timeout
	if not is_inside_tree():
		return
	state = State.PATROL
	_play("blink")


func _play(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func _on_hurt_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
