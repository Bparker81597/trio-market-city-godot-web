extends Control

# This is the scene we open after the loading screen finishes.
# The startup flow now goes from loading screen to title screen first.
@export var next_scene_path := "res://scenes/ui/TitleScreen.tscn"

# These references are assigned when we build the UI in code.
var progress_bar: ProgressBar
var loading_label: Label
var tip_label: Label
var title_label: Label
var subtitle_label: Label
var tagline_label: Label

# Decorative loading dots on the right side.
var glow_dots: Array[ColorRect] = []
var glow_dot_bases: Array[Vector2] = []

# Internal timers and animation state.
var progress := 0.0
var elapsed_time := 0.0
var status_timer: Timer
var tip_timer: Timer
var is_changing_scene := false

var messages := [
	"Loading Opportunity Plaza...",
	"Preparing Training Center...",
	"Opening Tool Market...",
	"Connecting Networking Hub...",
	"Unlocking Demo Arena...",
	"Building your future city..."
]

var tips := [
	"Talk to NPCs to unlock opportunities.",
	"Visit the Training Center to build skills.",
	"Complete missions to earn XP.",
	"Use the Tool Market to upgrade your workflow.",
	"Explore every district for hidden contracts."
]


func _ready() -> void:
	# Fill the full viewport.
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Build every visible element in code so the screen does not depend on old scene paths.
	_build_ui()
	_change_text()

	# Rotate status text frequently so the loading screen feels alive.
	status_timer = Timer.new()
	status_timer.wait_time = 1.4
	status_timer.autostart = true
	status_timer.timeout.connect(_change_loading_message)
	add_child(status_timer)

	# Rotate tips separately so they do not all change at the same time.
	tip_timer = Timer.new()
	tip_timer.wait_time = 2.8
	tip_timer.autostart = true
	tip_timer.timeout.connect(_change_tip)
	add_child(tip_timer)


func _process(delta: float) -> void:
	elapsed_time += delta

	# Progress is intentionally simple and reliable.
	# The first 92% fills steadily, then the final 8% eases in.
	if progress < 92.0:
		progress += delta * 28.0
	else:
		progress += delta * 9.0

	progress = minf(progress, 100.0)
	if progress_bar != null:
		progress_bar.value = progress

	# Soft pulse on the title and the loading status.
	var pulse := 0.85 + (sin(Time.get_ticks_msec() / 280.0) + 1.0) * 0.08
	if title_label != null:
		title_label.modulate = Color(1.0, 1.0, 1.0, pulse)
	if loading_label != null:
		loading_label.modulate = Color(0.88, 0.97, 1.0, 0.86 + 0.14 * sin(Time.get_ticks_msec() / 360.0))

	_animate_glow_dots()

	# Change scenes only once, and only if the target exists.
	if progress >= 100.0 and not is_changing_scene:
		is_changing_scene = true
		if ResourceLoader.exists(next_scene_path):
			get_tree().change_scene_to_file(next_scene_path)
		else:
			if loading_label != null:
				loading_label.text = "Next scene not found: " + next_scene_path


func _build_ui() -> void:
	# Background base color.
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.04, 0.09, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Two large glows fake a simple futuristic gradient without depending on textures.
	var left_glow := ColorRect.new()
	left_glow.color = Color(0.22, 0.10, 0.55, 0.16)
	left_glow.position = Vector2(0, 0)
	left_glow.size = Vector2(580, 900)
	add_child(left_glow)

	var right_glow := ColorRect.new()
	right_glow.color = Color(0.08, 0.55, 0.90, 0.14)
	right_glow.position = Vector2(780, 0)
	right_glow.size = Vector2(820, 900)
	add_child(right_glow)

	# Main left-side panel.
	var panel := PanelContainer.new()
	panel.position = Vector2(64, 88)
	panel.custom_minimum_size = Vector2(640, 470)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04, 0.07, 0.15, 0.86)
	panel_style.border_color = Color(0.14, 0.82, 1.0, 0.72)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 28
	panel_style.corner_radius_top_right = 28
	panel_style.corner_radius_bottom_left = 28
	panel_style.corner_radius_bottom_right = 28
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	panel_style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	title_label = Label.new()
	title_label.text = "TRIO Market City"
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", Color("f7fbff"))
	box.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "AI Workforce World"
	subtitle_label.add_theme_font_size_override("font_size", 30)
	subtitle_label.add_theme_color_override("font_color", Color("5ce9ff"))
	box.add_child(subtitle_label)

	tagline_label = Label.new()
	tagline_label.text = "Explore. Learn. Build. Earn. Impact."
	tagline_label.add_theme_font_size_override("font_size", 22)
	tagline_label.add_theme_color_override("font_color", Color("d8ff54"))
	box.add_child(tagline_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	box.add_child(spacer)

	loading_label = Label.new()
	loading_label.text = "Loading..."
	loading_label.add_theme_font_size_override("font_size", 22)
	loading_label.add_theme_color_override("font_color", Color("e4f7ff"))
	box.add_child(loading_label)

	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(560, 28)
	var progress_bg := StyleBoxFlat.new()
	progress_bg.bg_color = Color(0.09, 0.14, 0.24, 0.95)
	progress_bg.border_color = Color("2dc8ff")
	progress_bg.border_width_left = 2
	progress_bg.border_width_top = 2
	progress_bg.border_width_right = 2
	progress_bg.border_width_bottom = 2
	progress_bg.corner_radius_top_left = 16
	progress_bg.corner_radius_top_right = 16
	progress_bg.corner_radius_bottom_left = 16
	progress_bg.corner_radius_bottom_right = 16
	var progress_fill := StyleBoxFlat.new()
	progress_fill.bg_color = Color("8dff3f")
	progress_fill.corner_radius_top_left = 16
	progress_fill.corner_radius_top_right = 16
	progress_fill.corner_radius_bottom_left = 16
	progress_fill.corner_radius_bottom_right = 16
	progress_bar.add_theme_stylebox_override("background", progress_bg)
	progress_bar.add_theme_stylebox_override("fill", progress_fill)
	box.add_child(progress_bar)

	tip_label = Label.new()
	tip_label.text = "Tip loading..."
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_label.custom_minimum_size = Vector2(560, 70)
	tip_label.add_theme_font_size_override("font_size", 18)
	tip_label.add_theme_color_override("font_color", Color(0.86, 0.89, 0.93, 0.94))
	box.add_child(tip_label)

	# Simple right-side decorative city blocks.
	_build_city_blocks()

	# Small animated dots give the screen motion even with no textures.
	_build_glow_dots()


func _build_city_blocks() -> void:
	var building_specs := [
		{"pos": Vector2(920, 168), "size": Vector2(180, 250), "color": Color("305d93")},
		{"pos": Vector2(1110, 120), "size": Vector2(110, 300), "color": Color("3d91d9")},
		{"pos": Vector2(1240, 188), "size": Vector2(160, 228), "color": Color("765bdb")},
		{"pos": Vector2(1010, 470), "size": Vector2(210, 170), "color": Color("8a6b4f")},
		{"pos": Vector2(1250, 458), "size": Vector2(170, 180), "color": Color("ab2d74")}
	]

	for building_data in building_specs:
		var block := Panel.new()
		block.position = building_data["pos"]
		block.size = building_data["size"]
		var block_style := StyleBoxFlat.new()
		block_style.bg_color = building_data["color"]
		block_style.border_color = building_data["color"].lightened(0.24)
		block_style.border_width_left = 2
		block_style.border_width_top = 2
		block_style.border_width_right = 2
		block_style.border_width_bottom = 2
		block_style.corner_radius_top_left = 24
		block_style.corner_radius_top_right = 24
		block_style.corner_radius_bottom_left = 24
		block_style.corner_radius_bottom_right = 24
		block.add_theme_stylebox_override("panel", block_style)
		add_child(block)

		for row in range(3):
			for column in range(2):
				var window_rect := ColorRect.new()
				window_rect.color = Color(0.44, 0.93, 1.0, 0.74)
				window_rect.position = block.position + Vector2(26 + column * 42, 28 + row * 48)
				window_rect.size = Vector2(22, 26)
				add_child(window_rect)


func _build_glow_dots() -> void:
	var dot_positions := [
		Vector2(880, 90),
		Vector2(1010, 118),
		Vector2(1180, 96),
		Vector2(1320, 138),
		Vector2(1450, 112),
		Vector2(910, 702),
		Vector2(1120, 748),
		Vector2(1360, 712)
	]

	var dot_colors := [
		Color("4fe6ff"),
		Color("8c5aff"),
		Color("c7ff42"),
		Color("4fe6ff"),
		Color("ff58bc"),
		Color("8c5aff"),
		Color("4fe6ff"),
		Color("c7ff42")
	]

	for index in range(dot_positions.size()):
		var dot := ColorRect.new()
		dot.position = dot_positions[index]
		dot.size = Vector2(18, 18)
		dot.color = dot_colors[index]
		add_child(dot)
		glow_dots.append(dot)
		glow_dot_bases.append(dot_positions[index])


func _animate_glow_dots() -> void:
	var time := Time.get_ticks_msec() / 1000.0
	for index in range(glow_dots.size()):
		var dot := glow_dots[index]
		if dot == null:
			continue
		var base_position := glow_dot_bases[index]
		dot.position = base_position + Vector2(0.0, sin(time * 1.8 + index) * 8.0)
		var alpha := 0.55 + (sin(time * 2.6 + index * 0.6) + 1.0) * 0.22
		dot.modulate.a = alpha


func _change_text() -> void:
	_change_loading_message()
	_change_tip()


func _change_loading_message() -> void:
	if loading_label != null:
		loading_label.text = messages.pick_random()


func _change_tip() -> void:
	if tip_label != null:
		tip_label.text = tips.pick_random()
