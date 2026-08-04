extends Node2D

## Physically simulated pendulum: place this node at the fixed anchor point.
## The chain (and thus the swing arc) automatically scales with chain_length.

const GRAVITY = 980.0
const DAMAGE = 1
const LINK_SPACING = 8.0
const CHAIN_LINK_TEXTURE = preload("res://assets/Traps/Spiked Ball/Chain.png")

@export var chain_length: float = 64.0
@export var start_angle_degrees: float = 60.0
@export var damping: float = 0.0

var angle: float
var angular_velocity: float = 0.0

func _ready() -> void:
	$Ball.add_to_group("hazards")
	$Ball.body_entered.connect(_on_ball_body_entered)
	angle = deg_to_rad(start_angle_degrees)
	angular_velocity = 0.0
	_rebuild_chain()


func _physics_process(delta: float) -> void:
	var angular_acceleration = -(GRAVITY / chain_length) * sin(angle)
	angular_velocity += angular_acceleration * delta
	angular_velocity *= 1.0 - clampf(damping * delta, 0.0, 1.0)
	angle += angular_velocity * delta
	rotation = angle


func _rebuild_chain() -> void:
	for child in $Chain.get_children():
		child.queue_free()

	var link_count = int(chain_length / LINK_SPACING)
	for i in range(link_count):
		var link = Sprite2D.new()
		link.texture = CHAIN_LINK_TEXTURE
		link.position = Vector2(0, i * LINK_SPACING)
		$Chain.add_child(link)

	$Ball.position = Vector2(0, chain_length)


func _on_ball_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(DAMAGE)
