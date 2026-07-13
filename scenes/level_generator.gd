extends Node

# Grey stone border tiles
const STONE_TOP_LEFT  = Vector2i(0, 0)
const STONE_TOP       = Vector2i(1, 0)
const STONE_TOP_RIGHT = Vector2i(2, 0)
const STONE_LEFT      = Vector2i(0, 1)
const STONE_RIGHT     = Vector2i(2, 1)
const STONE_BOT_LEFT  = Vector2i(0, 2)
const STONE_BOT       = Vector2i(1, 2)
const STONE_BOT_RIGHT = Vector2i(2, 2)

# Green grass / dirt platform tiles
const GRASS_LEFT  = Vector2i(6, 0)
const GRASS_MID   = Vector2i(7, 0)
const GRASS_RIGHT = Vector2i(8, 0)
const DIRT_TOP    = Vector2i(6, 1)
const DIRT_MID    = Vector2i(6, 2)
const DIRT_BOT    = Vector2i(6, 3)

# Level dimensions — bigger and more spaced out
const LEVEL_LEFT   = 0
const LEVEL_RIGHT  = 40
const LEVEL_TOP    = -28
const LEVEL_BOTTOM = 0
const DIRT_DEPTH   = 2

# Platforms [start_x, end_x, y] — more spread out
const PLATFORMS = [
	# Ground floor
	[1, 39, 0],
	# Level 1
	[2, 8, -5],
	[15, 22, -5],
	[30, 38, -5],
	# Level 2
	[6, 13, -10],
	[24, 32, -10],
	# Level 3
	[2, 9, -15],
	[18, 26, -15],
	[32, 38, -15],
	# Level 4
	[8, 16, -20],
	[26, 34, -20],
	# Top checkpoint platform
	[14, 26, -26],
]

@onready var tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")

func _ready() -> void:
	generate_border()
	generate_platforms()

func generate_border() -> void:
	for x in range(LEVEL_LEFT, LEVEL_RIGHT + 1):
		for y in range(LEVEL_TOP, LEVEL_BOTTOM + 1):
			if y == LEVEL_TOP:
				if x == LEVEL_LEFT:
					tilemap.set_cell(Vector2i(x, y), 0, STONE_TOP_LEFT)
				elif x == LEVEL_RIGHT:
					tilemap.set_cell(Vector2i(x, y), 0, STONE_TOP_RIGHT)
				else:
					tilemap.set_cell(Vector2i(x, y), 0, STONE_TOP)
			elif y == LEVEL_BOTTOM:
				if x == LEVEL_LEFT:
					tilemap.set_cell(Vector2i(x, y), 0, STONE_BOT_LEFT)
				elif x == LEVEL_RIGHT:
					tilemap.set_cell(Vector2i(x, y), 0, STONE_BOT_RIGHT)
				else:
					tilemap.set_cell(Vector2i(x, y), 0, STONE_BOT)
			elif x == LEVEL_LEFT:
				tilemap.set_cell(Vector2i(x, y), 0, STONE_LEFT)
			elif x == LEVEL_RIGHT:
				tilemap.set_cell(Vector2i(x, y), 0, STONE_RIGHT)

func generate_platforms() -> void:
	for platform in PLATFORMS:
		var start_x: int = platform[0]
		var end_x:   int = platform[1]
		var y:       int = platform[2]
		var width:   int = end_x - start_x

		for x in range(start_x, end_x + 1):
			var surface_tile: Vector2i
			if width == 0:
				surface_tile = GRASS_MID
			elif x == start_x:
				surface_tile = GRASS_LEFT
			elif x == end_x:
				surface_tile = GRASS_RIGHT
			else:
				surface_tile = GRASS_MID
			tilemap.set_cell(Vector2i(x, y), 0, surface_tile)

			for d in range(1, DIRT_DEPTH + 1):
				var dirt_tile: Vector2i
				if d == 1:
					dirt_tile = DIRT_TOP
				elif d == DIRT_DEPTH:
					dirt_tile = DIRT_BOT
				else:
					dirt_tile = DIRT_MID
				tilemap.set_cell(Vector2i(x, y + d), 0, dirt_tile)
