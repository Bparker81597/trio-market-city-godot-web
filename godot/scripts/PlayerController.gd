extends CharacterBody3D
class_name PlayerController

signal prompt_changed(text: String, visible: bool)

const STEAMPUNK_WARRIOR_SCENE = preload("res://scenes/characters/SteampunkWarriorNPC.tscn")

@export var move_speed: float = 6.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 18.0
@export var camera_rotation_speed: float = 2.5
@export var camera_zoom_speed: float = 2.0
@export var min_zoom: float = 8.0
@export var max_zoom: float = 18.0

@onready var visual_root: Node3D = $VisualRoot
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var interaction_area: Area3D = $InteractionArea

var nearby_interactable: Node = null
var current_target: Node = null
var virtual_input_vector := Vector2.ZERO
var virtual_interact_pressed := false
var virtual_camera_left_pressed := false
var virtual_camera_right_pressed := false
var virtual_interact_last := false
var virtual_camera_left_last := false
var virtual_camera_right_last := false
var web_input_snapshot := "0000000"
var web_input_callback = null


func _ready() -> void:
	visual_root.position = Vector3.ZERO
	camera.position.z = clampf(camera.position.z, min_zoom, max_zoom)
	_install_visual_model()
	_install_web_input_callback()
	_refresh_interaction_prompt()
	if interaction_area != null:
		interaction_area.monitoring = true
		interaction_area.monitorable = true


func _physics_process(delta: float) -> void:
	_update_web_input_snapshot()
	handle_movement(delta)
	handle_camera(delta)
	_update_interaction_target()
	handle_interact()


func handle_movement(delta: float) -> void:
	var input_dir := Vector2.ZERO

	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	if web_input_snapshot.length() >= 4:
		if web_input_snapshot[2] == "1":
			input_dir.x -= 1.0
		if web_input_snapshot[3] == "1":
			input_dir.x += 1.0
		if web_input_snapshot[0] == "1":
			input_dir.y -= 1.0
		if web_input_snapshot[1] == "1":
			input_dir.y += 1.0

	input_dir += virtual_input_vector

	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	var direction := Vector3.ZERO

	if input_dir != Vector2.ZERO:
		var cam_basis := camera.global_transform.basis
		var forward := -cam_basis.z
		var right := cam_basis.x

		forward.y = 0.0
		right.y = 0.0
		forward = forward.normalized()
		right = right.normalized()

		direction = (right * input_dir.x + forward * input_dir.y).normalized()

		var target_angle := atan2(direction.x, direction.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()


func handle_camera(delta: float) -> void:
	if Input.is_action_pressed("camera_left"):
		camera_pivot.rotate_y(camera_rotation_speed * delta)

	if Input.is_action_pressed("camera_right"):
		camera_pivot.rotate_y(-camera_rotation_speed * delta)

	if virtual_camera_left_pressed and not virtual_camera_left_last:
		rotate_camera_left()
	if virtual_camera_right_pressed and not virtual_camera_right_last:
		rotate_camera_right()

	virtual_camera_left_last = virtual_camera_left_pressed
	virtual_camera_right_last = virtual_camera_right_pressed

	if InputMap.has_action("camera_zoom_in") and Input.is_action_just_pressed("camera_zoom_in"):
		camera.position.z = maxf(camera.position.z - camera_zoom_speed, min_zoom)

	if InputMap.has_action("camera_zoom_out") and Input.is_action_just_pressed("camera_zoom_out"):
		camera.position.z = minf(camera.position.z + camera_zoom_speed, max_zoom)


func handle_interact() -> void:
	var interact_pressed := Input.is_action_just_pressed("interact")
	if virtual_interact_pressed and not virtual_interact_last:
		interact_pressed = true
	virtual_interact_last = virtual_interact_pressed

	if not interact_pressed:
		return

	if nearby_interactable != null and nearby_interactable.has_method("interact"):
		nearby_interactable.call("interact")
	elif current_target != null and current_target.has_method("interact"):
		current_target.call("interact")
	else:
		prompt_changed.emit("No interaction target nearby.", true)


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


func trigger_interact() -> void:
	var previous_state := virtual_interact_pressed
	virtual_interact_pressed = true
	handle_interact()
	virtual_interact_pressed = previous_state
	virtual_interact_last = previous_state


func rotate_camera_left() -> void:
	camera_pivot.rotate_y(deg_to_rad(45.0))


func rotate_camera_right() -> void:
	camera_pivot.rotate_y(deg_to_rad(-45.0))


func _install_visual_model() -> void:
	for child in visual_root.get_children():
		child.queue_free()

	var character_loaded := false
	if STEAMPUNK_WARRIOR_SCENE != null:
		var meshy_instance = STEAMPUNK_WARRIOR_SCENE.instantiate()
		if meshy_instance is Node3D:
			var meshy_character := meshy_instance as Node3D
			meshy_character.name = "MeshyCharacter"
			meshy_character.position = Vector3(0.0, 0.88, 0.0)
			meshy_character.scale = Vector3.ONE * 0.02
			visual_root.add_child(meshy_character)
			_play_preview_animation(meshy_character)
			character_loaded = true

	if not character_loaded:
		_add_placeholder_mesh()

	_add_selection_ring()
	_add_player_tag()


func _play_preview_animation(node: Node) -> void:
	var animation_player := _find_animation_player(node)
	if animation_player == null:
		return

	var animation_names := animation_player.get_animation_list()
	if animation_names.is_empty():
		return

	var selected_animation: StringName = animation_names[0]
	for animation_name in animation_names:
		if String(animation_name).to_lower().contains("run"):
			selected_animation = animation_name
			break

	animation_player.speed_scale = 0.35
	animation_player.play(selected_animation)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _add_placeholder_mesh() -> void:
	var placeholder := MeshInstance3D.new()
	placeholder.name = "PlaceholderMesh"
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = 1.2
	placeholder.mesh = capsule
	placeholder.position = Vector3(0.0, 0.95, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("36d8ff")
	material.emission_enabled = true
	material.emission = Color("7ae6ff")
	material.emission_energy_multiplier = 1.2
	placeholder.material_override = material
	visual_root.add_child(placeholder)


func _add_selection_ring() -> void:
	var ring := MeshInstance3D.new()
	ring.name = "SelectionRing"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.72
	mesh.bottom_radius = 0.82
	mesh.height = 0.06
	ring.mesh = mesh
	ring.position = Vector3(0.0, 0.03, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("4df3ff")
	material.emission_enabled = true
	material.emission = Color("6df7ff")
	material.emission_energy_multiplier = 1.4
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.78
	ring.material_override = material
	visual_root.add_child(ring)


func _add_player_tag() -> void:
	var label := Label3D.new()
	label.name = "PlayerTag"
	label.text = "YOU"
	label.font_size = 34
	label.position = Vector3(0.0, 2.8, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 8
	label.outline_modulate = Color(0.04, 0.12, 0.2, 0.95)
	label.modulate = Color("f3fbff")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visual_root.add_child(label)


func _update_interaction_target() -> void:
	var best_target: Node = null
	var best_distance := INF

	for interactable in get_tree().get_nodes_in_group("interactable"):
		if not interactable.has_method("can_interact"):
			continue
		if not interactable.can_interact(global_position):
			if interactable.has_method("set_highlighted"):
				interactable.set_highlighted(false)
			continue

		var interactable_node := interactable as Node3D
		if interactable_node == null:
			continue

		var distance := global_position.distance_to(interactable_node.global_position)
		if distance < best_distance:
			best_distance = distance
			best_target = interactable

	for interactable in get_tree().get_nodes_in_group("interactable"):
		if interactable.has_method("set_highlighted"):
			interactable.set_highlighted(interactable == best_target)

	current_target = best_target
	nearby_interactable = best_target
	_refresh_interaction_prompt()


func _refresh_interaction_prompt() -> void:
	if current_target != null and current_target.has_method("get_prompt_text"):
		prompt_changed.emit(current_target.get_prompt_text(), true)
	else:
		prompt_changed.emit("", false)


func _update_web_input_snapshot() -> void:
	if OS.get_name() != "Web":
		web_input_snapshot = "0000000"
		return

	var snapshot = JavaScriptBridge.eval("window.trioInputSnapshot || '0000000'", true)
	if snapshot is String:
		web_input_snapshot = snapshot
	else:
		web_input_snapshot = "0000000"


func _install_web_input_callback() -> void:
	if OS.get_name() != "Web":
		return

	web_input_callback = JavaScriptBridge.create_callback(_on_web_input_snapshot)
	var window = JavaScriptBridge.get_interface("window")
	window.trioGodotInputCallback = web_input_callback
	window.trioGodotInputReady = true


func _on_web_input_snapshot(args: Array) -> void:
	if args.is_empty():
		return
	web_input_snapshot = str(args[0])
