extends AnimatableBody2D
## Movement mode: automatic back-and-forth, or triggered by the player landing on top.
@export_enum("Automatic", "Player Triggered") var move_mode: String = "Automatic"
## Offset (direction + distance) the block slides to, relative to its start position.
@export var move_offset: Vector2 = Vector2(48, 0)
@export var move_speed: float = 80.0
## Pause after landing/reaching a point before the block moves again.
@export var trigger_delay: float = 0.15
## If true, the block slides back to its start position and can be triggered again. (Player Triggered mode only)
@export var resets: bool = true
@export var reset_delay: float = 1.5

var _start_position: Vector2
var _target_position: Vector2
var _is_sliding: bool = false
var _has_triggered: bool = false

func _ready() -> void:
	_start_position = position
	$TopDetector.body_entered.connect(_on_top_detector_body_entered)

	if move_mode == "Automatic":
		_target_position = _start_position + move_offset
		_is_sliding = true

func _physics_process(delta: float) -> void:
	if not _is_sliding:
		return
	position = position.move_toward(_target_position, move_speed * delta)
	if not position.is_equal_approx(_target_position):
		return
	_is_sliding = false

	if move_mode == "Automatic":
		await get_tree().create_timer(trigger_delay).timeout
		_target_position = _start_position if _target_position.is_equal_approx(_start_position + move_offset) else _start_position + move_offset
		_is_sliding = true
		return

	# Player Triggered mode
	if position.is_equal_approx(_start_position):
		_has_triggered = false
	elif resets:
		await get_tree().create_timer(reset_delay).timeout
		_slide_to(_start_position)

func _on_top_detector_body_entered(body: Node) -> void:
	if move_mode != "Player Triggered" or _has_triggered or not body.is_in_group("player"):
		return
	_has_triggered = true
	$AnimatedSprite2D.play("hit_top")
	await get_tree().create_timer(trigger_delay).timeout
	_slide_to(_start_position + move_offset)

func _slide_to(target: Vector2) -> void:
	_target_position = target
	_is_sliding = true
