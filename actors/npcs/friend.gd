extends CharacterBody2D

## A rescuable friend. Place one anywhere in the level and set character_name
## to any of the player skins below. Walking into it counts the rescue and
## teleports the friend away.

const CHARACTER_FRAMES = {
	"Pink Man": preload("res://actors/player/frames/pink_man.tres"),
	"Mask Dude": preload("res://actors/player/frames/mask_dude.tres"),
	"Ninja Frog": preload("res://actors/player/frames/ninja_frog.tres"),
	"Virtual Guy": preload("res://actors/player/frames/virtual_guy.tres"),
}

@export var character_name: String = "Pink Man"

var is_rescued = false

func _ready() -> void:
	add_to_group("npcs")

	if not CHARACTER_FRAMES.has(character_name):
		push_warning("Unknown character: %s" % character_name)
		character_name = "Pink Man"

	$AnimatedSprite2D.sprite_frames = CHARACTER_FRAMES[character_name]
	$AnimatedSprite2D.play("idle")
	$RescueArea.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if is_rescued or not body.is_in_group("player"):
		return

	is_rescued = true
	RescueTracker.register_rescue(character_name)
	_teleport_away()


func _teleport_away() -> void:
	$RescueArea/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)

	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property($AnimatedSprite2D, "scale", Vector2(0.4, 0.4), 0.3)
	await tween.finished
	queue_free()
