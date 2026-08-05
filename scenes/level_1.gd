extends Node2D

func _enter_tree() -> void:
	# _enter_tree runs top-down (parent before children), so this clears the
	# trackers before any Friend/Pineapple child registers itself in _ready,
	# which would otherwise double-count on scene reload/restart.
	RescueTracker.reset()
	PineappleTracker.reset()


func _ready() -> void:
	# _ready runs bottom-up (children before parent), so every Friend/Pineapple
	# has already registered its spawn by the time the HUD reads the totals.
	var hud = preload("res://scenes/hud.gd").new()
	add_child(hud)
