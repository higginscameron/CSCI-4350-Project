extends CharacterBody2D

const DAMAGE = 1
const STOMP_BOUNCE = -250.0
const FIRE_COOLDOWN = 0.9
const LAUNCH_FRAME = 4

@export var facing_direction: float = -1.0
@export var bullet_scene: PackedScene = preload("res://actors/enemies/plant/bullet.tscn")

var is_dead = false
var player_in_range: Node = null
var _fire_cooldown: float = 0.0
var _bullet_fired_this_attack = false


func _ready() -> void:
	add_to_group("enemies")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$DetectionArea.body_entered.connect(_on_detection_area_body_entered)
	$DetectionArea.body_exited.connect(_on_detection_area_body_exited)
	$HitBox.body_entered.connect(_on_hit_box_body_entered)
	_play("idle")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta

	if player_in_range != null:
		facing_direction = (
			-1.0
			if player_in_range.global_position.x < global_position.x
			else 1.0
		)

	$AnimatedSprite2D.flip_h = facing_direction > 0

	if (
		player_in_range != null
		and _fire_cooldown <= 0.0
		and $AnimatedSprite2D.animation != "attack"
	):
		_attack()


func _attack() -> void:
	_fire_cooldown = FIRE_COOLDOWN
	_bullet_fired_this_attack = false
	$AnimatedSprite2D.play("attack")


func _on_frame_changed() -> void:
	if (
		$AnimatedSprite2D.animation == "attack"
		and $AnimatedSprite2D.frame == LAUNCH_FRAME
		and not _bullet_fired_this_attack
	):
		_bullet_fired_this_attack = true
		_spawn_bullet()


func _spawn_bullet() -> void:
	if bullet_scene == null or player_in_range == null:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = $Muzzle.global_position
	bullet.direction = facing_direction


func _play(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func _on_animation_finished() -> void:
	match $AnimatedSprite2D.animation:
		"attack":
			_play("idle")
		"hit":
			queue_free()


func _on_detection_area_body_entered(body: Node) -> void:
	if is_dead or not body.is_in_group("player"):
		return

	player_in_range = body


func _on_detection_area_body_exited(body: Node) -> void:
	if body == player_in_range:
		player_in_range = null


func _on_hit_box_body_entered(body: Node) -> void:
	if is_dead or not body.is_in_group("player"):
		return

	if body.velocity.y > 0:
		_die(body)


func _die(player: Node) -> void:
	is_dead = true
	player_in_range = null
	velocity = Vector2.ZERO

	$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)

	if player.has_method("play_stomp_sound"):
		player.play_stomp_sound()

	player.velocity.y = STOMP_BOUNCE
	_play("hit")