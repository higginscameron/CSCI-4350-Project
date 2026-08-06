extends Area2D

const SPEED = 360.0
const DAMAGE = 1
const LIFETIME = 3.0

@export var direction: float = -1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += direction * SPEED * delta
	$Sprite2D.flip_h = direction > 0


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(DAMAGE)
	queue_free()
