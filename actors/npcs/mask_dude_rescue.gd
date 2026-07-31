extends CharacterBody2D

@export var rescue_character_name: String = "Mask Dude"
@export var follow_speed: float = 60.0
@export var follow_offset: Vector2 = Vector2(-32, -6)

var is_rescued: bool = false
var target_player: CharacterBody2D

func _ready() -> void:
	add_to_group("npcs")
	if has_node("RescueArea"):
		$RescueArea.body_entered.connect(_on_body_entered)
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.sprite_frames = load("res://actors/player/frames/mask_dude.tres")
		$AnimatedSprite2D.rotation = deg_to_rad(-90)
		$AnimatedSprite2D.play("idle")
	if has_node("CollisionShape2D"):
		$CollisionShape2D.rotation = deg_to_rad(-90)
	if has_node("RescueArea/CollisionShape2D"):
		$RescueArea/CollisionShape2D.rotation = deg_to_rad(-90)

func _physics_process(_delta: float) -> void:
	if not is_rescued or target_player == null:
		return

	var target_sprite = target_player.get_node_or_null("AnimatedSprite2D")
	var offset_x = follow_offset.x
	if target_sprite != null and target_sprite.flip_h:
		offset_x = -follow_offset.x

	var target_position = target_player.global_position + Vector2(offset_x, follow_offset.y)
	var direction = target_position - global_position
	if direction.length() > 1.0:
		velocity = direction.normalized() * follow_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = velocity.x < 0

func _on_body_entered(body: Node) -> void:
	if is_rescued or body == null or not body.is_in_group("player"):
		return

	is_rescued = true
	target_player = body
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.sprite_frames = load("res://actors/player/frames/mask_dude.tres")
		$AnimatedSprite2D.play("idle")
	if has_node("RescueArea"):
		$RescueArea/CollisionShape2D.set_deferred("disabled", true)
