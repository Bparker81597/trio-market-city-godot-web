extends Control

const WebBridgeRef = preload("res://scripts/WebBridge.gd")
const TITLE_TEXTURE: Texture2D = preload("res://assets/ui/trio-market-city-title.png")

@export var world_scene_path := "res://scenes/Main.tscn"

var background_rect: TextureRect
var menu_root: Control
var menu_buttons: VBoxContainer
var menu_heading: Label
var fade_overlay: ColorRect
var settings_popup: PanelContainer
var start_button: Button
var continue_button: Button
var demo_button: Button
var settings_button: Button
var exit_button: Button
var web_start_world_callback: Variant

var animation_time := 0.0
var is_transitioning := false
var waiting_for_intro := false
var menu_root_position := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_install_web_intro_bridge()
	_build_background()
	_build_menu_panel()
	_build_settings_popup()
	_build_fade_overlay()
	_update_layout()
	_play_menu_intro()
	resized.connect(_update_layout)
	if start_button != null:
		start_button.grab_focus()
	if OS.has_feature("web"):
		WebBridgeRef.post_event({"type": "GODOT_TITLE_READY"})


func _process(delta: float) -> void:
	animation_time += delta
	_animate_background()
	_float_menu_panel()
	_pulse_primary_button()
	if waiting_for_intro and _consume_web_world_start():
		fade_to_game()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and settings_popup != null and settings_popup.visible:
		settings_popup.visible = false


func _build_background() -> void:
	background_rect = TextureRect.new()
	background_rect.texture = TITLE_TEXTURE
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_rect)

	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.02, 0.04, 0.08, 0.16)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)


func _build_menu_panel() -> void:
	menu_root = Control.new()
	menu_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(menu_root)

	menu_heading = Label.new()
	menu_heading.text = "Build skills. Create impact. Win the future."
	menu_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_heading.add_theme_font_size_override("font_size", 16)
	menu_heading.add_theme_color_override("font_color", Color(0.92, 0.97, 1.0, 0.96))
	menu_heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(menu_heading)

	menu_buttons = VBoxContainer.new()
	menu_buttons.add_theme_constant_override("separation", 14)
	menu_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(menu_buttons)

	start_button = _make_menu_button("Start Journey", true, Callable(self, "_on_start_pressed"))
	menu_buttons.add_child(start_button)

	continue_button = _make_menu_button("Continue", false, Callable(self, "_on_continue_pressed"))
	menu_buttons.add_child(continue_button)

	demo_button = _make_menu_button("Demo Mode", false, Callable(self, "_on_demo_pressed"))
	menu_buttons.add_child(demo_button)

	settings_button = _make_menu_button("Settings", false, Callable(self, "_on_settings_pressed"))
	menu_buttons.add_child(settings_button)

	exit_button = _make_menu_button("Exit", false, Callable(self, "_on_exit_pressed"))
	menu_buttons.add_child(exit_button)


func _make_menu_button(label_text: String, is_primary: bool, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0.0, 58.0)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("f7fcff"))
	button.add_theme_font_override("font", ThemeDB.fallback_font)
	button.add_theme_constant_override("outline_size", 0)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_stylebox_override("normal", _button_style(false, is_primary))
	button.add_theme_stylebox_override("hover", _button_style(true, is_primary))
	button.add_theme_stylebox_override("pressed", _button_style(true, is_primary))
	button.add_theme_stylebox_override("focus", _button_style(true, is_primary))
	button.pressed.connect(callback)
	button.button_down.connect(func(): _play_click_animation(button))
	button.mouse_entered.connect(func(): _animate_hover(button, true))
	button.mouse_exited.connect(func(): _animate_hover(button, false))
	button.focus_entered.connect(func(): _animate_hover(button, true))
	button.focus_exited.connect(func(): _animate_hover(button, false))
	return button


func _build_settings_popup() -> void:
	settings_popup = PanelContainer.new()
	settings_popup.visible = false
	settings_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_popup.add_theme_stylebox_override("panel", _popup_style())
	add_child(settings_popup)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	settings_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("f6fbff"))
	box.add_child(title)

	var description := Label.new()
	description.text = "Settings coming soon."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size", 18)
	description.add_theme_color_override("font_color", Color("d8ebff"))
	box.add_child(description)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(0.0, 48.0)
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	close_button.add_theme_stylebox_override("normal", _popup_button_style(false))
	close_button.add_theme_stylebox_override("hover", _popup_button_style(true))
	close_button.add_theme_stylebox_override("pressed", _popup_button_style(true))
	close_button.add_theme_stylebox_override("focus", _popup_button_style(true))
	close_button.pressed.connect(func(): settings_popup.visible = false)
	box.add_child(close_button)


func _build_fade_overlay() -> void:
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_overlay)


func _button_style(active: bool, is_primary: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.12, 0.22, 0.60)
	if is_primary:
		style.bg_color = Color(0.26, 0.86, 1.0, 0.98) if active else Color(0.20, 0.78, 0.98, 0.94)
	style.border_color = Color(0.55, 0.91, 1.0, 0.92 if active else (0.78 if is_primary else 0.38))
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0.16, 0.82, 1.0, 0.42 if active or is_primary else 0.12)
	style.shadow_size = 24 if active or is_primary else 10
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.2
	return style


func _popup_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.07, 0.12, 0.94)
	style.border_color = Color(0.32, 0.82, 1.0, 0.54)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
	style.shadow_size = 24
	return style


func _popup_button_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17385f").lightened(0.08) if active else Color("17385f")
	style.border_color = Color("78e3ff")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style


func _update_layout() -> void:
	var button_width := clampf(size.x * 0.285, 390.0, 440.0)
	var total_height := 58.0 * 5.0 + 14.0 * 4.0
	var heading_height := 30.0
	menu_root_position = Vector2(
		clampf(size.x * 0.455 - button_width * 0.5, 240.0, size.x - button_width - 90.0),
		clampf(size.y * 0.51, 330.0, size.y - total_height - heading_height - 50.0)
	)
	menu_root.position = menu_root_position
	menu_root.size = Vector2(button_width, heading_height + 12.0 + total_height)
	menu_heading.position = Vector2(4.0, 0.0)
	menu_heading.size = Vector2(button_width - 8.0, heading_height)
	menu_buttons.position = Vector2(0.0, heading_height + 12.0)
	menu_buttons.size = Vector2(button_width, total_height)
	for button in [start_button, continue_button, demo_button, settings_button, exit_button]:
		if button != null:
			button.custom_minimum_size = Vector2(button_width, 58.0)

	settings_popup.anchor_left = 0.5
	settings_popup.anchor_right = 0.5
	settings_popup.anchor_top = 0.5
	settings_popup.anchor_bottom = 0.5
	settings_popup.offset_left = -170.0
	settings_popup.offset_right = 170.0
	settings_popup.offset_top = -86.0
	settings_popup.offset_bottom = 86.0


func _play_menu_intro() -> void:
	menu_root.modulate.a = 0.0
	menu_root.position = menu_root_position + Vector2(-14.0, 12.0)
	var tween := create_tween()
	tween.tween_property(menu_root, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(menu_root, "position", menu_root_position, 0.40).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _animate_background() -> void:
	var zoom := 1.015 + sin(animation_time * 0.15) * 0.010
	background_rect.scale = Vector2.ONE * zoom
	background_rect.position = Vector2(
		-((zoom - 1.0) * size.x * 0.5) + sin(animation_time * 0.07) * 8.0,
		-((zoom - 1.0) * size.y * 0.5) + cos(animation_time * 0.09) * 5.0
	)


func _float_menu_panel() -> void:
	if menu_root == null or is_transitioning:
		return
	menu_root.position = menu_root_position + Vector2(0.0, sin(animation_time * 1.3) * 3.0)


func _pulse_primary_button() -> void:
	if start_button == null or is_transitioning:
		return
	if start_button.has_focus() or start_button.is_hovered():
		return
	var pulse := 1.0 + (sin(animation_time * 2.2) + 1.0) * 0.012
	start_button.scale = Vector2.ONE * pulse


func _animate_hover(button: Button, hovered: bool) -> void:
	if button == null:
		return
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2.ONE * (1.03 if hovered else 1.0), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _play_click_animation(button: Button) -> void:
	if button == null:
		return
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2.ONE * 0.985, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _install_web_intro_bridge() -> void:
	if not OS.has_feature("web"):
		return
	web_start_world_callback = JavaScriptBridge.create_callback(_on_web_start_world)
	var window = JavaScriptBridge.get_interface("window")
	window.trioTitleStartWorldCallback = web_start_world_callback
	JavaScriptBridge.eval("""
		window.trioPendingWorldStart = false;
		if (!window.trioTitleBridgeInstalled) {
			window.trioStartWorld = function () {
				window.trioPendingWorldStart = true;
				if (window.trioTitleStartWorldCallback) {
					window.trioTitleStartWorldCallback();
				}
			};
			window.addEventListener("message", function (event) {
				if (event?.data?.type === "TRIO_START_WORLD") {
					window.trioPendingWorldStart = true;
					if (window.trioTitleStartWorldCallback) {
						window.trioTitleStartWorldCallback();
					}
				}
			});
			window.trioTitleBridgeInstalled = true;
		}
	""", true)


func _consume_web_world_start() -> bool:
	if not OS.has_feature("web"):
		return false
	var should_start = JavaScriptBridge.eval("window.trioPendingWorldStart === true", true)
	if should_start is bool and should_start:
		JavaScriptBridge.eval("window.trioPendingWorldStart = false;", true)
		return true
	return false


func _on_web_start_world(_args: Array) -> void:
	if not waiting_for_intro or is_transitioning:
		return
	JavaScriptBridge.eval("window.trioPendingWorldStart = false;", true)
	call_deferred("fade_to_game")


func _set_menu_disabled(disabled: bool) -> void:
	for button in [start_button, continue_button, demo_button, settings_button, exit_button]:
		if button != null:
			button.disabled = disabled


func _request_intro(run_demo: bool) -> void:
	if is_transitioning or waiting_for_intro:
		return
	waiting_for_intro = true
	settings_popup.visible = false
	_set_menu_disabled(true)
	fade_overlay.color = Color(0.0, 0.0, 0.0, 0.16)
	WebBridgeRef.post_event({"type": "TRIO_START_DEMO_INTRO" if run_demo else "TRIO_START_INTRO"})


func fade_to_game() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	waiting_for_intro = false
	_set_menu_disabled(true)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.52).timeout
	get_tree().change_scene_to_file(world_scene_path)


func _on_start_pressed() -> void:
	if OS.has_feature("web"):
		_request_intro(false)
		return
	fade_to_game()


func _on_continue_pressed() -> void:
	if OS.has_feature("web"):
		_request_intro(false)
		return
	fade_to_game()


func _on_demo_pressed() -> void:
	if OS.has_feature("web"):
		_request_intro(true)
		return
	fade_to_game()


func _on_settings_pressed() -> void:
	settings_popup.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()
