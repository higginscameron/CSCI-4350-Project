extends Node

signal rescue_registered(character_name: String, total_rescued: int)

var total_placed: int = 0
var total_rescued: int = 0

func reset() -> void:
	total_placed = 0
	total_rescued = 0

func register_friend_spawn() -> void:
	total_placed += 1

func register_rescue(character_name: String) -> void:
	total_rescued += 1
	rescue_registered.emit(character_name, total_rescued)

func all_rescued() -> bool:
	return total_rescued >= total_placed
