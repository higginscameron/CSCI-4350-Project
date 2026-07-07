extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0

# Each rescued friend becomes a playable character with the same animation
# names, so switching is just a matter of swapping the SpriteFrames resource.
const CHARACTER_FRAMES = {
	"Pink Man": preload("res://actors/player/frames/pink_man.tres"),
	"Mask Dude": preload("res://actors/player/frames/mask_dude.tres"),
	"Ninja Frog": preload("res://actors/player/frames/ninja_frog.tres"),
	"Virtual Guy": preload("res://actors/player/frames/virtual_guy.tres"),
}

@export var current_character: String = "Pink Man"

var health = 3
var spawn_position = Vector2.ZERO
var is_hit = false

func _ready() -> void:
	add_to_group("player")
	spawn_position = global_position
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	set_character(current_character)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Left / right movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_update_animation(direction)


func _update_animation(direction: float) -> void:
	# Don't let idle/run/jump/fall interrupt a hit reaction mid-play.
	if is_hit:
		return

	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0

	if not is_on_floor():
		_play("jump" if velocity.y < 0 else "fall")
	elif direction != 0:
		_play("run")
	else:
		_play("idle")


func _play(anim_name: String) -> void:
	# Avoid restarting an animation that's already playing.
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
	health -= amount
	is_hit = true
	$AnimatedSprite2D.play("hit")
	if health <= 0:
		die()


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		is_hit = false


func die() -> void:
	queue_free()


func respawn() -> void:
	health = 3
	is_hit = false
	global_position = spawn_position
	velocity = Vector2.ZERO
