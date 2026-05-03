extends Node3D

const WebBridgeRef = preload("res://scripts/WebBridge.gd")

@onready var prompt_panel: PanelContainer = $UI/InteractionPrompt
@onready var prompt_label: Label = $UI/InteractionPrompt/Label
@onready var player: PlayerController = $Player
@onready var world_environment: WorldEnvironment = $Lighting/WorldEnvironment
@onready var city_builder: CityBuilder = $World

var active_waypoint := "client_district"
var last_camera_signal := ""
var last_district_highlight := ""
var web_input_snapshot := "0000000"
var last_web_input_snapshot := "0000000"
var last_player_position := Vector3.ZERO


func _ready() -> void:
	print("MAIN SCENE PATH:", get_tree().current_scene.scene_file_path)
	_configure_input_map()
	_style_prompt_panel()
	_setup_environment()
	_build_native_controls()
	player.prompt_changed.connect(_on_prompt_changed)
	city_builder.set_waypoint_target(active_waypoint)
	last_player_position = player.global_position
	# Keep the world playable even if the browser bridge fails.


func _on_prompt_changed(text: String, visible: bool) -> void:
	prompt_panel.visible = visible
	prompt_label.text = text


func _process(delta: float) -> void:
	web_input_snapshot = _get_web_input_snapshot()
	_apply_web_movement_fallback(delta, web_input_snapshot)
	_apply_web_action_fallback(web_input_snapshot)
	city_builder.update_player_guidance(player.global_position)
	last_web_input_snapshot = web_input_snapshot
	last_player_position = player.global_position


func _apply_web_movement_fallback(delta: float, snapshot: String) -> void:
	if snapshot.length() < 4:
		return

	var input_x := 0.0
	var input_z := 0.0
	if snapshot[2] == "1":
		input_x -= 1.0
	if snapshot[3] == "1":
		input_x += 1.0
	if snapshot[0] == "1":
		input_z -= 1.0
	if snapshot[1] == "1":
		input_z += 1.0

	var input_vector := Vector2(input_x, input_z)
	if input_vector == Vector2.ZERO:
		return
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	# Only take over if the player controller did not already move this frame.
	if player.global_position.distance_to(last_player_position) > 0.01:
		return

	player.global_position += Vector3(input_vector.x, 0.0, input_vector.y) * 5.8 * delta


func _apply_web_action_fallback(snapshot: String) -> void:
	if snapshot.length() < 7:
		return

	var previous := last_web_input_snapshot
	while previous.length() < 7:
		previous += "0"

	if snapshot[4] == "1" and previous[4] != "1":
		player.trigger_interact()
	if snapshot[5] == "1" and previous[5] != "1":
		player.rotate_camera_left()
	if snapshot[6] == "1" and previous[6] != "1":
		player.rotate_camera_right()


func _get_web_input_snapshot() -> String:
	if OS.get_name() != "Web":
		return "0000000"

	var snapshot = JavaScriptBridge.eval("window.trioInputSnapshot || '0000000'", true)
	if snapshot is String:
		return snapshot
	return "0000000"


func _build_native_controls() -> void:
	var controls_root := Control.new()
	controls_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	controls_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(controls_root)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	panel.offset_left = -210
	panel.offset_top = -212
	panel.offset_right = -28
	panel.offset_bottom = -28
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	controls_root.add_child(panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.09, 0.16, 0.78)
	panel_style.border_color = Color("6ed9ff")
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 18
	panel_style.corner_radius_top_right = 18
	panel_style.corner_radius_bottom_left = 18
	panel_style.corner_radius_bottom_right = 18
	panel.add_theme_stylebox_override("panel", panel_style)

	var title := Label.new()
	title.text = "In-Game Move"
	title.position = Vector2(12, 8)
	title.add_theme_color_override("font_color", Color("dff7ff"))
	panel.add_child(title)

	var up := _make_control_button("Up", Vector2(58, 26), Vector2(54, 32))
	panel.add_child(up)
	up.button_down.connect(func(): player.set_virtual_input(Vector2(0, -1)))
	up.button_up.connect(func(): player.set_virtual_input(Vector2.ZERO))

	var left := _make_control_button("Left", Vector2(10, 66), Vector2(48, 32))
	panel.add_child(left)
	left.button_down.connect(func(): player.set_virtual_input(Vector2(-1, 0)))
	left.button_up.connect(func(): player.set_virtual_input(Vector2.ZERO))

	var down := _make_control_button("Down", Vector2(58, 66), Vector2(54, 32))
	panel.add_child(down)
	down.button_down.connect(func(): player.set_virtual_input(Vector2(0, 1)))
	down.button_up.connect(func(): player.set_virtual_input(Vector2.ZERO))

	var right := _make_control_button("Right", Vector2(112, 66), Vector2(48, 32))
	panel.add_child(right)
	right.button_down.connect(func(): player.set_virtual_input(Vector2(1, 0)))
	right.button_up.connect(func(): player.set_virtual_input(Vector2.ZERO))

	var interact := _make_control_button("E", Vector2(10, 112), Vector2(48, 34))
	panel.add_child(interact)
	interact.button_down.connect(func(): player.set_virtual_action("interact", true))
	interact.button_up.connect(func(): player.set_virtual_action("interact", false))

	var cam_left := _make_control_button("Q", Vector2(62, 112), Vector2(48, 34))
	panel.add_child(cam_left)
	cam_left.button_down.connect(func(): player.set_virtual_action("camera_left", true))
	cam_left.button_up.connect(func(): player.set_virtual_action("camera_left", false))

	var cam_right := _make_control_button("R", Vector2(114, 112), Vector2(48, 34))
	panel.add_child(cam_right)
	cam_right.button_down.connect(func(): player.set_virtual_action("camera_right", true))
	cam_right.button_up.connect(func(): player.set_virtual_action("camera_right", false))


func _make_control_button(text: String, pos: Vector2, size_value: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = size_value
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_NONE
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.12, 0.2, 0.34, 0.96)
	button_style.border_color = Color("7adfff")
	button_style.border_width_left = 1
	button_style.border_width_top = 1
	button_style.border_width_right = 1
	button_style.border_width_bottom = 1
	button_style.corner_radius_top_left = 12
	button_style.corner_radius_top_right = 12
	button_style.corner_radius_bottom_left = 12
	button_style.corner_radius_bottom_right = 12
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_stylebox_override("pressed", button_style)
	button.add_theme_stylebox_override("hover", button_style)
	button.add_theme_color_override("font_color", Color("effbff"))
	return button


func _configure_input_map() -> void:
	_map_key("move_forward", KEY_W)
	_map_key("move_forward", KEY_UP)
	_map_key("move_back", KEY_S)
	_map_key("move_back", KEY_DOWN)
	_map_key("move_left", KEY_A)
	_map_key("move_left", KEY_LEFT)
	_map_key("move_right", KEY_D)
	_map_key("move_right", KEY_RIGHT)
	_map_key("interact", KEY_E)
	_map_key("camera_left", KEY_Q)
	_map_key("camera_right", KEY_R)


func _map_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return
	var input := InputEventKey.new()
	input.keycode = keycode
	InputMap.action_add_event(action, input)


func _style_prompt_panel() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.96, 0.98, 1.0, 0.88)
	style.border_color = Color("75cbff")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	prompt_panel.add_theme_stylebox_override("panel", style)
	prompt_label.add_theme_color_override("font_color", Color("173255"))
	prompt_label.add_theme_font_size_override("font_size", 22)
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("c9e8f6")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("eaf4fb")
	env.ambient_light_energy = 0.62
	env.fog_enabled = true
	env.fog_light_color = Color("d8eef9")
	env.fog_light_energy = 0.08
	env.adjustment_enabled = true
	env.adjustment_brightness = 0.92
	env.adjustment_contrast = 1.02
	env.adjustment_saturation = 0.96
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.environment = env
