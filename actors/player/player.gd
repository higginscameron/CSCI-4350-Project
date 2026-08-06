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

@onready var walking_sfx: AudioStreamPlayer = $WalkingSFX
@onready var jumping_sfx: AudioStreamPlayer = $JumpingSFX
@onready var stomp_sfx: AudioStreamPlayer = $BiteTheCurbSFX
@onready var death_sfx: AudioStreamPlayer = $DeathSFX
@onready var hurt_sfx: AudioStreamPlayer = $HurtSFX
@onready var wall_slide_sfx: AudioStreamPlayer = $WallSlideSFX
@onready var DeathTracker: Node = get_node("/root/DeathTracker")

var health = 3
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

	# Update wall slide state.
	if is_on_floor():
		jump_count = 0
		is_wall_sliding = false
	elif is_touching_wall and velocity.y > 0:
		is_wall_sliding = true
	else:
		is_wall_sliding = false

	# Apply gravity.
	if is_wall_sliding:
		velocity.y += WALL_SLIDE_GRAVITY * delta
	else:
		velocity.y += GRAVITY * delta

	# Handle jumping.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			jumping_sfx.play()

		elif is_touching_wall and not is_on_floor():
			velocity.y = JUMP_VELOCITY

			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * SPEED

			jump_count = 0
			_play("wall_jump")
			jumping_sfx.play()

		elif jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			jumping_sfx.play()

	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	_update_walking_sound(direction)
	_update_wall_slide_sound()
	_update_animation(direction)


func _update_walking_sound(direction: float) -> void:
	var is_running := (
		is_on_floor()
		and direction != 0
		and not is_hit
		and not is_dying
	)

	if is_running:
		if not walking_sfx.playing:
			walking_sfx.play()
	else:
		if walking_sfx.playing:
			walking_sfx.stop()


func _update_wall_slide_sound() -> void:
	var should_play := (
		is_wall_sliding
		and not is_hit
		and not is_dying
	)

	if should_play:
		if not wall_slide_sfx.playing:
			wall_slide_sfx.play()
	else:
		if wall_slide_sfx.playing:
			wall_slide_sfx.stop()


func _update_animation(direction: float) -> void:
	if is_hit:
		return

	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0

	# Protect the wall-jump animation while moving upward.
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

	# Use the death sound instead of the hurt sound on the final hit.
	if health <= 0:
		die()
		return

	is_hit = true
	walking_sfx.stop()
	wall_slide_sfx.stop()

	# Restart the hurt sound cleanly if the player is hit again quickly.
	if hurt_sfx.playing:
		hurt_sfx.stop()

	hurt_sfx.play()
	$AnimatedSprite2D.play("hit")


func heal(amount: int) -> void:
	# max(health, MAX_HEALTH) keeps this a no-op above MAX_HEALTH instead of
	# slamming an inflated testing health value back down to 3.
	health = min(health + amount, max(health, MAX_HEALTH))


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit" and not is_dying:
		is_hit = false


func play_stomp_sound() -> void:
	if stomp_sfx.playing:
		stomp_sfx.stop()

	stomp_sfx.play()


func die() -> void:
	if is_dying:
		return

	is_dying = true
	death_sfx.play()
	$AnimatedSprite2D.play("hit")
	velocity = Vector2.ZERO
	set_physics_process(false)

	var tween = create_tween()

	tween.tween_property(
		self,
		"modulate",
		Color(1, 0.35, 0.35, 0.5),
		0.2
	)

	tween.tween_property(
		self,
		"modulate",
		Color(1, 1, 1, 0.1),
		0.15
	)

	tween.tween_callback(
		func():
			modulate = Color(1, 1, 1, 1)
			$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	)

	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(0.35).timeout

	$AnimatedSprite2D.modulate = Color(1.4, 1.4, 1.4, 1.0)

	await get_tree().create_timer(0.08).timeout

	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(0.2).timeout

	# Let the death sound finish before reloading.
	if death_sfx.playing:
		await death_sfx.finished

	get_tree().reload_current_scene()
