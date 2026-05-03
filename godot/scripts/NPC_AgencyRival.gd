extends Node3D

const WebBridgeRef = preload("res://scripts/WebBridge.gd")
const STEAMPUNK_WARRIOR_SCENE = preload("res://scenes/SteampunkWarriorNPC.tscn")

@export var npc_id := "npc_agency_rival"
@export var npc_name := "NPC Agency Rival"
@export var mission_id := "boss_pitch_battle"

var player_near := false
var last_interact_frame := -1
var pulse_time := 0.0
var mesh_materials: Array[StandardMaterial3D] = []
var mesh_root_base_y := 0.0
var base_glow_energy := 0.22
var active_glow_energy := 0.95

@onready var label: Label3D = $Label3D
@onready var area: Area3D = $Area3D
@onready var mesh_root: Node3D = _ensure_meshy_model()
@onready var subtitle_label: Label3D = _create_subtitle_label()
@onready var selection_ring: MeshInstance3D = _create_selection_ring()
@onready var shadow_disc: MeshInstance3D = _create_shadow_disc()
@onready var fallback_visual: Node3D = _create_fallback_placeholder()
@onready var alert_label: Label3D = _create_alert_marker()


func _ready() -> void:
	add_to_group("interactable")
	global_position.y = 0.0
	label.text = npc_name
	mesh_root.name = "MeshyModel"
	mesh_root.visible = true
	mesh_root.position = Vector3(0.0, 0.0, 0.0)
	mesh_root.rotation_degrees = Vector3.ZERO
	mesh_root.scale = Vector3(1.2, 1.2, 1.2)
	mesh_root_base_y = mesh_root.position.y
	area.body_entered.connect(_on_area_3d_body_entered)
	area.body_exited.connect(_on_area_3d_body_exited)
	force_meshes_visible(self)
	_configure_mesh_glow()
	_apply_glow(base_glow_energy)
	if is_instance_valid(fallback_visual):
		fallback_visual.queue_free()


func _process(delta: float) -> void:
	pulse_time += delta
	_update_idle_pose()
	if player_near and Input.is_action_just_pressed("interact"):
		start_boss_challenge()


func can_interact(_player_position: Vector3) -> bool:
	return player_near


func get_prompt_text() -> String:
	return "Press E: Challenge Rival"


func interact() -> void:
	start_boss_challenge()


func set_highlighted(active: bool) -> void:
	label.modulate = Color("ffffff") if active else Color("d7ecff")
	subtitle_label.modulate = Color("fff0ce") if active else Color("d2d9e8")
	alert_label.modulate = Color("fff4a3") if active else Color("ffd95f")
	mesh_root.scale = Vector3.ONE * (1.28 if active else 1.2)
	selection_ring.scale = Vector3.ONE * (1.06 if active else 1.0)
	shadow_disc.scale = Vector3.ONE * (1.04 if active else 1.0)


func _open_mission() -> void:
	var current_frame := Engine.get_process_frames()
	if current_frame == last_interact_frame:
		return
	last_interact_frame = current_frame
	WebBridgeRef.open_mission({
		"type": "OPEN_MISSION",
		"sourceType": "npc",
		"sourceId": npc_id,
		"sourceName": npc_name,
		"npcId": npc_id,
		"npcName": npc_name,
		"npcRole": "Boss",
		"dialogPreview": "Beat the rival agency by choosing the stronger client strategy.",
		"missionId": mission_id,
		"title": "NPC Agency Rival",
		"objective": "Beat the rival agency by choosing the stronger client strategy.",
		"rewardMoney": 1200,
		"rewardXP": 50,
		"rewardReputation": 18,
		"publicFund": 80,
		"skill": "Communication + Business Strategy",
		"reward": "$1200 + 50 XP + 18 Reputation + Public Fund +$80"
	})


func start_boss_challenge() -> void:
	print("Boss Challenge Started")
	_open_mission()
	_dispatch_boss_challenge_event()


func _on_area_3d_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_near = true
		label.text = npc_name
		alert_label.text = "!"
		_apply_glow(active_glow_energy)


func _on_area_3d_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		label.text = npc_name
		alert_label.text = "!"
		_apply_glow(base_glow_energy)


func _create_selection_ring() -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	ring.name = "BossSelectionRing"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.45
	mesh.bottom_radius = 1.7
	mesh.height = 0.08
	ring.mesh = mesh
	ring.position = Vector3(0.0, 0.04, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.95, 1.0, 0.82)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color("57f1ff")
	material.emission_energy_multiplier = 1.55
	ring.material_override = material
	add_child(ring)
	move_child(ring, 0)
	return ring


func _create_shadow_disc() -> MeshInstance3D:
	var shadow := MeshInstance3D.new()
	shadow.name = "BossShadow"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.05
	mesh.bottom_radius = 1.25
	mesh.height = 0.02
	shadow.mesh = mesh
	shadow.position = Vector3(0.0, 0.01, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.03, 0.03, 0.05, 0.6)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow.material_override = material
	add_child(shadow)
	move_child(shadow, 0)
	return shadow


func _create_subtitle_label() -> Label3D:
	var subtitle := Label3D.new()
	subtitle.name = "SubtitleLabel3D"
	subtitle.text = "Competing for contracts"
	subtitle.position = Vector3(0.0, 2.85, 0.0)
	subtitle.font_size = 18
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.outline_size = 6
	subtitle.outline_modulate = Color(0.05, 0.05, 0.08, 0.82)
	subtitle.modulate = Color("d2d9e8")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(subtitle)
	return subtitle


func _create_alert_marker() -> Label3D:
	var marker := Label3D.new()
	marker.name = "AlertLabel3D"
	marker.text = "!"
	marker.position = Vector3(0.0, 4.1, 0.0)
	marker.font_size = 42
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker.outline_size = 8
	marker.outline_modulate = Color(0.06, 0.08, 0.14, 0.92)
	marker.modulate = Color("ffd95f")
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(marker)
	return marker


func _update_idle_pose() -> void:
	var bounce := sin(pulse_time * 1.35)
	mesh_root.position.y = mesh_root_base_y + bounce * 0.04
	mesh_root.rotation.y = sin(pulse_time * 0.7) * 0.06
	label.position.y = 3.35 + bounce * 0.03
	subtitle_label.position.y = 2.85 + bounce * 0.02
	alert_label.position.y = 4.1 + bounce * 0.05
	selection_ring.scale = Vector3.ONE * (1.0 + 0.03 * sin(pulse_time * 2.2))
	shadow_disc.scale = Vector3.ONE * (1.0 + 0.035 * bounce)


func _configure_mesh_glow() -> void:
	mesh_materials.clear()
	_collect_mesh_materials(mesh_root)


func _ensure_meshy_model() -> Node3D:
	var existing := get_node_or_null("MeshyModel") as Node3D
	if existing != null:
		return existing

	var fallback_scene := STEAMPUNK_WARRIOR_SCENE.instantiate() as Node3D
	fallback_scene.name = "MeshyModel"
	add_child(fallback_scene)
	move_child(fallback_scene, 0)
	return fallback_scene


func _create_fallback_placeholder() -> Node3D:
	var placeholder := Node3D.new()
	placeholder.name = "NPCVisualFallback"
	placeholder.position = Vector3.ZERO
	add_child(placeholder)

	var body := MeshInstance3D.new()
	body.name = "FallbackBody"
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.35
	body_mesh.height = 0.9
	body.mesh = body_mesh
	body.position = Vector3(0.0, 1.0, 0.0)
	body.material_override = _fallback_material(Color(0.28, 0.88, 1.0, 1.0), 1.2)
	placeholder.add_child(body)

	var head := MeshInstance3D.new()
	head.name = "FallbackHead"
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.24
	head.mesh = head_mesh
	head.position = Vector3(0.0, 1.95, 0.0)
	head.material_override = _fallback_material(Color(0.93, 0.98, 1.0, 1.0), 1.45)
	placeholder.add_child(head)

	var fallback_label := Label3D.new()
	fallback_label.name = "FallbackLabel3D"
	fallback_label.text = "NPC VISUAL FALLBACK"
	fallback_label.position = Vector3(0.0, 2.7, 0.0)
	fallback_label.font_size = 18
	fallback_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	fallback_label.outline_size = 6
	fallback_label.outline_modulate = Color(0.05, 0.08, 0.1, 0.95)
	fallback_label.modulate = Color(1.0, 0.98, 0.72, 1.0)
	fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.add_child(fallback_label)

	return placeholder


func _fallback_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	return material


func _collect_mesh_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.material_override is StandardMaterial3D:
			var override_material := (mesh_instance.material_override as StandardMaterial3D).duplicate()
			override_material.emission_enabled = true
			mesh_instance.material_override = override_material
			mesh_materials.append(override_material)
		elif mesh_instance.mesh != null:
			var surface_count := mesh_instance.mesh.get_surface_count()
			for surface_index in range(surface_count):
				var surface_material = mesh_instance.mesh.surface_get_material(surface_index)
				if surface_material is StandardMaterial3D:
					var next_material := (surface_material as StandardMaterial3D).duplicate()
					next_material.emission_enabled = true
					mesh_instance.set_surface_override_material(surface_index, next_material)
					mesh_materials.append(next_material)

	for child in node.get_children():
		_collect_mesh_materials(child)


func force_meshes_visible(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		mesh_instance.visible = true
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	for child in node.get_children():
		force_meshes_visible(child)


func _apply_glow(energy: float) -> void:
	for material in mesh_materials:
		material.emission_enabled = true
		material.emission = Color("7ad9ff")
		material.emission_energy_multiplier = energy


func _dispatch_boss_challenge_event() -> void:
	if OS.get_name() != "Web":
		return

	JavaScriptBridge.eval("""
		window.dispatchEvent(new CustomEvent('START_BOSS_CHALLENGE', {
			detail: {
				npc: "NPC Agency Rival",
				title: "Demo Arena Pitch Battle",
				objective: "Outperform the rival agency with a stronger solution",
				reward: 1200
			}
		}));
	""", true)
