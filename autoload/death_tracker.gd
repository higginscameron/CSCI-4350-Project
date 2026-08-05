extends Node

signal death_registered(total_deaths: int)

var total_deaths: int = 0

func reset() -> void:
	total_deaths = 0

func register_death() -> void:
	total_deaths += 1
	death_registered.emit(total_deaths)
