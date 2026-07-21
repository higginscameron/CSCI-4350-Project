extends Control

@export var max_health: int = 3
@export var corner_radius: float = 5.0
var player: CharacterBody2D
var health_bar_fill: ColorRect

func _ready() -> void:
    player = get_parent()

    # Create background (dark gray)
    var bg = ColorRect.new()
    bg.color = Color.DARK_GRAY
    bg.size = Vector2(50, 10)
    _add_rounded_corners(bg)
    add_child(bg)

    # Create fill bar (green)
    health_bar_fill = ColorRect.new()
    health_bar_fill.color = Color.GREEN
    health_bar_fill.size = Vector2(50, 10)
    _add_rounded_corners(health_bar_fill)
    add_child(health_bar_fill)

    # Position above player (centered)
    position = Vector2(-25, -30)

func _add_rounded_corners(color_rect: ColorRect) -> void:
    var shader_material = ShaderMaterial.new()
    var shader = Shader.new()
    shader.code = """
    shader_type canvas_item;

    uniform float radius : hint_range(0.0, 50.0) = 5.0;

    void fragment() {
        vec2 size = UV * COLOR.xy;
        vec2 center = size / 2.0;
        vec2 diff = abs(UV - center);
        float max_diff = max(diff.x, diff.y);

        vec2 p = abs(UV - 0.5);
        float d = length(max(p - vec2(0.5 - radius / 100.0), 0.0));

        if (d > radius / 100.0) {
            discard;
        }

        COLOR = COLOR;
    }
    """
    shader_material.shader = shader
    shader_material.set_shader_parameter("radius", corner_radius)
    color_rect.material = shader_material

func _physics_process(_delta: float) -> void:
    # Update health bar width based on current health
    var health_percent = float(player.health) / float(max_health)
    health_bar_fill.size.x = 50 * health_percent