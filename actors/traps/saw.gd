extends Area2D

const DAMAGE = 1

@export var move_distance: float = 64.0
@export var speed: float = 40.0
@export var move_direction := Vector2.RIGHT

var _start_position: Vector2
var _progress: float = 0.0
var _direction_sign: float = 1.0

func _ready() -> void:
	add_to_group("hazards")
	_start_position = position
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_progress += speed * _direction_sign * delta
	if _progress >= move_distance:
		_progress = move_distance
		_direction_sign = -1.0
	elif _progress <= 0.0:
		_progress = 0.0
		_direction_sign = 1.0
	position = _start_position + move_direction.normalized() * _progress


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(DAMAGE)
