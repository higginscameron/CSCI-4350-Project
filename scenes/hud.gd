extends CanvasLayer

var pineapple_label: Label
var friend_label: Label
var death_label: Label

func _ready() -> void:
	layer = 5

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	pineapple_label = _make_label()
	friend_label = _make_label()
	death_label = _make_label()
	vbox.add_child(pineapple_label)
	vbox.add_child(friend_label)
	vbox.add_child(death_label)

	PineappleTracker.pineapple_registered.connect(_on_pineapple_registered)
	RescueTracker.rescue_registered.connect(_on_rescue_registered)
	DeathTracker.death_registered.connect(_on_death_registered)

	_refresh()


func _make_label() -> Label:
	var label = Label.new()
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	return label


func _refresh() -> void:
	pineapple_label.text = "Pineapples: %d/%d" % [PineappleTracker.total_collected, PineappleTracker.total_placed]
	friend_label.text = "Friends: %d/%d" % [RescueTracker.total_rescued, RescueTracker.total_placed]
	death_label.text = "Deaths: %d" % DeathTracker.total_deaths


func _on_pineapple_registered(_total: int) -> void:
	_refresh()


func _on_rescue_registered(_character_name: String, _total: int) -> void:
	_refresh()


func _on_death_registered(_total: int) -> void:
	_refresh()
