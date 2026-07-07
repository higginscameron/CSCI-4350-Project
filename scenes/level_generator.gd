extends Node

# Tile atlas coordinates
const GRASS_LEFT   = Vector2i(6, 0)
const GRASS_MID    = Vector2i(7, 0)
const GRASS_RIGHT  = Vector2i(8, 0)
const DIRT_TOP     = Vector2i(6, 1)
const DIRT_MID     = Vector2i(6, 2)
const DIRT_BOT     = Vector2i(6, 3)

# Platforms [start_x, end_x, y]
const PLATFORMS = [
	[0,  20,  0],
	[3,   7, -4],
	[10, 14, -4],
	[17, 20, -4],
	[1,   5, -8],
	[8,  12, -8],
	[15, 19, -8],
	[3,   7, -12],
	[11, 15, -12],
	[1,   5, -16],
	[13, 17, -16],
	[5,  10, -20],
	[12, 16, -20],
	[8,  13, -24],
]

const FLOOR_DEPTH = 3

@onready var tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")

func _ready() -> void:
	generate()

func generate() -> void:
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

			for d in range(1, FLOOR_DEPTH + 1):
				var dirt_tile: Vector2i
				if d == 1:
					dirt_tile = DIRT_TOP
				elif d == FLOOR_DEPTH:
					dirt_tile = DIRT_BOT
				else:
					dirt_tile = DIRT_MID
				tilemap.set_cell(Vector2i(x, y + d), 0, dirt_tile)
