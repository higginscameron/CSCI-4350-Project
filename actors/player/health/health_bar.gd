extends Control

@export var max_health: int = 3
@export var bar_width: int = 64
@export var bar_height: int = 8
@export var segment_size: int = 8

var player: CharacterBody2D

var outline: Panel
var health_bar_bg: Panel
var health_bar_fill: Panel


func _ready() -> void:
	player = get_parent()

	# ------------------------
	# OUTLINE
	# ------------------------
	outline = Panel.new()
	outline.position = Vector2(-1, -1)
	outline.size = Vector2(bar_width + 2, bar_height + 2)

	var outline_style = StyleBoxFlat.new()
	outline_style.bg_color = Color.BLACK
	outline.add_theme_stylebox_override("panel", outline_style)

	add_child(outline)

	# ------------------------
	# BACKGROUND
	# ------------------------
	health_bar_bg = Panel.new()
	health_bar_bg.position = Vector2.ZERO
	health_bar_bg.size = Vector2(bar_width, bar_height)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15)
	health_bar_bg.add_theme_stylebox_override("panel", bg_style)

	add_child(health_bar_bg)

	# ------------------------
	# FILL
	# ------------------------
	health_bar_fill = Panel.new()
	health_bar_fill.position = Vector2.ZERO
	health_bar_fill.size = Vector2(bar_width, bar_height)

	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.18, 0.85, 0.18)
	health_bar_fill.add_theme_stylebox_override("panel", fill_style)

	add_child(health_bar_fill)

	# ------------------------
	# SEGMENTS
	# ------------------------
	for i in range(1, bar_width / segment_size):
		var bg_line = ColorRect.new()
		bg_line.color = Color.BLACK
		bg_line.size = Vector2(1, bar_height)
		bg_line.position = Vector2(i * segment_size, 0)
		health_bar_bg.add_child(bg_line)

		var fill_line = ColorRect.new()
		fill_line.color = Color.BLACK
		fill_line.size = Vector2(1, bar_height)
		fill_line.position = Vector2(i * segment_size, 0)
		health_bar_fill.add_child(fill_line)

	# Position above the player
	position = Vector2(-bar_width / 2, -30)


func _physics_process(_delta: float) -> void:
	if player == null:
		return

	var health_percent = clampf(
		float(player.health) / float(max_health),
		0.0,
		1.0
	)

	# Snap fill to segments
	var pixels = floor((bar_width * health_percent) / segment_size) * segment_size
	health_bar_fill.size.x = max(pixels, 0)

	# Smooth color transition
	var fill_style := health_bar_fill.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	fill_style.bg_color = _get_health_color(health_percent)
	health_bar_fill.add_theme_stylebox_override("panel", fill_style)


func _get_health_color(percent: float) -> Color:
	var green = Color(0.18, 0.85, 0.18)
	var yellow = Color(0.95, 0.85, 0.18)
	var red = Color(0.88, 0.18, 0.18)

	if percent > 0.5:
		# Green -> Yellow
		return yellow.lerp(green, (percent - 0.5) / 0.5)
	else:
		# Yellow -> Red
		return red.lerp(yellow, percent / 0.5)