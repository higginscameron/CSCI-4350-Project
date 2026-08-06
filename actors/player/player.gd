extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const WALL_SLIDE_GRAVITY = 150.0
const MAX_JUMPS = 2
const MAX_HEALTH = 3

const CHARACTER_FRAMES = {
	"Pink Man": preload("res://actors/player/frames/pink_man.tres"),
	"Mask Dude": preload("res://actors/player/frames/mask_dude.tres"),
	"Ninja Frog": preload("res://actors/player/frames/ninja_frog.tres"),
	"Virtual Guy": preload("res://actors/player/frames/virtual_guy.tres"),
}

@export var current_character: String = "Pink Man"

var health = 20000
var is_hit = false
var jump_count = 0
var is_dying = false
var is_wall_sliding = false

func _ready() -> void:
	add_to_group("player")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	set_character(current_character)


func _physics_process(delta: float) -> void:
	var is_touching_wall = is_on_wall()

	# Update wall slide state
	if is_on_floor():
		jump_count = 0
		is_wall_sliding = false
	elif is_touching_wall and velocity.y > 0:
		is_wall_sliding = true
	else:
		is_wall_sliding = false

	# Apply gravity (reduced on wall slide)
	if is_wall_sliding:
		velocity.y += WALL_SLIDE_GRAVITY * delta
	else:
		velocity.y += GRAVITY * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# Ground jump
			velocity.y = JUMP_VELOCITY
			jump_count += 1
		elif is_touching_wall and not is_on_floor():
			# Wall jump: push away from wall
			velocity.y = JUMP_VELOCITY
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * SPEED
			jump_count = 0
			_play("wall_jump")
		elif jump_count < MAX_JUMPS:
			# Air/double jump
			velocity.y = JUMP_VELOCITY
			jump_count += 1

	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_update_animation(direction)


func _update_animation(direction: float) -> void:
	if is_hit:
		return

	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0

	# Only protect wall_jump animation while moving upward
	if $AnimatedSprite2D.animation == "wall_jump" and velocity.y < 0:
		return

	if not is_on_floor():
		if is_wall_sliding:
			_play("fall")
		elif velocity.y < 0:
			_play("double_jump" if jump_count >= 2 else "jump")
		else:
			_play("fall")
	elif direction != 0:
		_play("run")
	else:
		_play("idle")


func _play(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.play(anim_name)


func set_character(character_name: String) -> void:
	if not CHARACTER_FRAMES.has(character_name):
		push_warning("Unknown character: %s" % character_name)
		return
	current_character = character_name
	$AnimatedSprite2D.sprite_frames = CHARACTER_FRAMES[character_name]
	$AnimatedSprite2D.play("idle")


func take_damage(amount: int) -> void:
	if is_dying:
		return

	health -= amount
	is_hit = true
	$AnimatedSprite2D.play("hit")
	if health <= 0:
		die()


func heal(amount: int) -> void:
	# max(health, MAX_HEALTH) keeps this a no-op above MAX_HEALTH instead of
	# slamming an inflated testing health value back down to 3.
	health = min(health + amount, max(health, MAX_HEALTH))


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		is_hit = false


func die() -> void:
	if is_dying:
		return

	is_dying = true
	DeathTracker.register_death()
	$AnimatedSprite2D.play("hit")
	velocity = Vector2.ZERO
	set_physics_process(false)

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.35, 0.35, 0.5), 0.2)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0.1), 0.15)
	tween.tween_callback(func():
		modulate = Color(1, 1, 1, 1)
		$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	)
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.35).timeout
	$AnimatedSprite2D.modulate = Color(1.4, 1.4, 1.4, 1.0)
	await get_tree().create_timer(0.08).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.2).timeout

	get_tree().reload_current_scene()
