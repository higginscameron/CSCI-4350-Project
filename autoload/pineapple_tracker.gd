extends Node

signal pineapple_registered(total_collected: int)

var total_placed: int = 0
var total_collected: int = 0

func reset() -> void:
	total_placed = 0
	total_collected = 0

func register_pineapple_spawn() -> void:
	total_placed += 1

func register_pineapple() -> void:
	total_collected += 1
	pineapple_registered.emit(total_collected)

func all_collected() -> bool:
	return total_collected >= total_placed
