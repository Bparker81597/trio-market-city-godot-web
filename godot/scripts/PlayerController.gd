extends CharacterBody3D
class_name PlayerController

signal prompt_changed(text: String, visible: bool)

@export var move_speed := 5.8
@export var rotation_speed := 10.0
@export var gravity := 9.8
@export var min_zoom := 10.0
@export var max_zoom := 22.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var zoom_distance := 16.0
var orbit_yaw := 45.0
var current_target: Node = null
var avatar_root: Node3D
var selection_ring: MeshInstance3D
var avatar_name_label: Label3D
var idle_time := 0.0
var interact_zoom_timer := 0.0
var external_focus_timer := 0.0
var shake_timer := 0.0
var shake_strength := 0.0
var debug_label: Label3D
var ground_anchor_y := 0.0
var virtual_input_vector := Vector2.ZERO
var virtual_interact_pressed := false
var virtual_camera_left_pressed := false
var virtual_camera_right_pressed := false
var virtual_camera_left_last := false
var virtual_camera_right_last := false
var virtual_interact_last := false


func _ready() -> void:
	_build_avatar()
	camera.position = Vector3(0, 0, zoom_distance)
	ground_anchor_y = global_position.y
	_build_debug_label()


func _physics_process(delta: float) -> void:
	idle_time += delta
	var input_x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_z := Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	if InputMap.has_action("move_back"):
		input_z = max(input_z, Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))

	input_x += virtual_input_vector.x
	input_z += virtual_input_vector.y

	var input_vector := Vector2(input_x, input_z)
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		var local_direction := Vector3(input_vector.x, 0.0, input_vector.y).normalized()
		var world_direction := (Basis(Vector3.UP, deg_to_rad(orbit_yaw)) * local_direction).normalized()
		var planar_velocity := world_direction * move_speed
		global_position += planar_velocity * delta
		velocity.x = planar_velocity.x
		velocity.z = planar_velocity.z
		rotation.y = lerp_angle(rotation.y, atan2(-world_direction.x, -world_direction.z), rotation_speed * delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	global_position.y = ground_anchor_y
	velocity.y = 0.0
	_update_avatar_fx(delta)
	_update_camera(delta)
	_update_interaction_target()
	_handle_web_action_inputs()
	_update_debug_label(input_vector)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_target != null:
		interact_zoom_timer = 0.28
		current_target.interact()
		return

	if event.is_action_pressed("camera_left"):
		orbit_yaw -= 45.0
	if event.is_action_pressed("camera_right"):
		orbit_yaw += 45.0

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_distance = max(min_zoom, zoom_distance - 1.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_distance = min(max_zoom, zoom_distance + 1.1)


func _get_web_input_vector() -> Vector2:
	return Vector2.ZERO


func _handle_web_action_inputs() -> void:
	if virtual_interact_pressed and not virtual_interact_last:
		if current_target != null:
			interact_zoom_timer = 0.28
			current_target.interact()
	virtual_interact_last = virtual_interact_pressed

	if virtual_camera_left_pressed and not virtual_camera_left_last:
		orbit_yaw -= 45.0
	virtual_camera_left_last = virtual_camera_left_pressed

	if virtual_camera_right_pressed and not virtual_camera_right_last:
		orbit_yaw += 45.0
	virtual_camera_right_last = virtual_camera_right_pressed


func set_virtual_input(input_vector: Vector2) -> void:
	virtual_input_vector = input_vector


func set_virtual_action(action: String, pressed: bool) -> void:
	match action:
		"interact":
			virtual_interact_pressed = pressed
		"camera_left":
			virtual_camera_left_pressed = pressed
		"camera_right":
			virtual_camera_right_pressed = pressed

func _update_camera(delta: float) -> void:
	camera_pivot.rotation_degrees.x = lerp(camera_pivot.rotation_degrees.x, -38.0, 6.0 * delta)
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, deg_to_rad(orbit_yaw), 6.0 * delta)
	interact_zoom_timer = max(0.0, interact_zoom_timer - delta)
	external_focus_timer = max(0.0, external_focus_timer - delta)
	shake_timer = max(0.0, shake_timer - delta)
	var zoom_target := zoom_distance
	if interact_zoom_timer > 0.0:
		zoom_target -= 1.2 * (interact_zoom_timer / 0.28)
	if external_focus_timer > 0.0:
		zoom_target -= 0.9 * (external_focus_timer / 0.36)
	camera.position = camera.position.lerp(Vector3(0, 0, zoom_target), 6.0 * delta)

	var shake_offset := Vector3.ZERO
	if shake_timer > 0.0:
		var shake_ratio := shake_timer / max(0.001, 0.42)
		shake_offset.x = sin(idle_time * 48.0) * shake_strength * shake_ratio
		shake_offset.y = cos(idle_time * 42.0) * shake_strength * 0.7 * shake_ratio
	camera.position += shake_offset


func _update_interaction_target() -> void:
	var best_target: Node = null
	var best_distance := 9999.0

	for interactable in get_tree().get_nodes_in_group("interactable"):
		if not interactable.has_method("can_interact"):
			continue
		if not interactable.can_interact(global_position):
			interactable.set_highlighted(false)
			continue
		var distance := global_position.distance_to(interactable.global_position)
		if distance < best_distance:
			best_distance = distance
			best_target = interactable

	for interactable in get_tree().get_nodes_in_group("interactable"):
		if interactable.has_method("set_highlighted"):
			interactable.set_highlighted(interactable == best_target)

	current_target = best_target
	if current_target != null and current_target.has_method("get_prompt_text"):
		prompt_changed.emit(current_target.get_prompt_text(), true)
	else:
		prompt_changed.emit("", false)


func _build_avatar() -> void:
	avatar_root = Node3D.new()
	add_child(avatar_root)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.38
	body_mesh.height = 1.1
	body.mesh = body_mesh
	body.position = Vector3(0, 0.95, 0)
	body.material_override = _solid_material(Color("4b88ff"))
	avatar_root.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.26
	head.mesh = head_mesh
	head.position = Vector3(0, 1.72, 0)
	head.material_override = _solid_material(Color("ffd7bf"))
	avatar_root.add_child(head)

	var backpack := MeshInstance3D.new()
	var backpack_mesh := BoxMesh.new()
	backpack_mesh.size = Vector3(0.34, 0.48, 0.22)
	backpack.mesh = backpack_mesh
	backpack.position = Vector3(0, 1.0, -0.22)
	backpack.material_override = _solid_material(Color("7c4dff"))
	avatar_root.add_child(backpack)

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.74
	ring_mesh.bottom_radius = 0.74
	ring_mesh.height = 0.08
	ring.mesh = ring_mesh
	ring.position = Vector3(0, 0.05, 0)
	ring.material_override = _emissive_material(Color("52f2b1"), 1.2)
	avatar_root.add_child(ring)
	selection_ring = ring

	var name_label := Label3D.new()
	name_label.text = "TRIO Fellow"
	name_label.font_size = 28
	name_label.position = Vector3(0, 2.35, 0)
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.outline_size = 8
	name_label.outline_modulate = Color(1, 1, 1, 0.95)
	name_label.modulate = Color("1d4f83")
	avatar_root.add_child(name_label)
	avatar_name_label = name_label


func _update_avatar_fx(_delta: float) -> void:
	if avatar_root == null:
		return
	var bounce := sin(idle_time * 2.2) * 0.05
	avatar_root.position.y = bounce
	if selection_ring != null:
		var pulse := 1.0 + (0.04 * (sin(idle_time * 3.0) + 1.0))
		selection_ring.scale = Vector3.ONE * pulse


func _build_debug_label() -> void:
	debug_label = Label3D.new()
	debug_label.font_size = 18
	debug_label.position = Vector3(0, 3.2, 0)
	debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	debug_label.outline_size = 6
	debug_label.outline_modulate = Color(1, 1, 1, 0.95)
	debug_label.modulate = Color("163d5f")
	avatar_root.add_child(debug_label)


func _update_debug_label(input_vector: Vector2) -> void:
	if debug_label == null:
		return
	var control_flags := "BTN %d%d%d%d" % [
		int(virtual_input_vector.y < 0.0),
		int(virtual_input_vector.y > 0.0),
		int(virtual_input_vector.x < 0.0),
		int(virtual_input_vector.x > 0.0)
	]
	debug_label.text = "IN %.2f, %.2f\nPOS %.2f, %.2f\nVEL %.2f, %.2f\n%s" % [input_vector.x, input_vector.y, global_position.x, global_position.z, velocity.x, velocity.z, control_flags]


func trigger_panel_focus() -> void:
	external_focus_timer = 0.36


func trigger_camera_shake(strength: float = 0.12) -> void:
	shake_timer = 0.42
	shake_strength = strength


func _solid_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material


func _emissive_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color.darkened(0.3)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material
