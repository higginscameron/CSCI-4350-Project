extends Node

signal rescue_registered(character_name: String, total_rescued: int)

var total_rescued: int = 0

func register_rescue(character_name: String) -> void:
	total_rescued += 1
	rescue_registered.emit(character_name, total_rescued)
