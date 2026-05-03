extends Area3D
class_name DistrictZone

const WebBridgeRef = preload("res://scripts/WebBridge.gd")

@export var zone_id := "home_base"
@export var zone_name := "Home Base"
@export var zone_type := "hub"
@export var mission_id := "reflection_planning"
@export var zone_description := "Explore this district to improve skills and opportunities."

var player_inside := false
var glow_mesh: MeshInstance3D
var label_node: Label3D
var waypoint_beam: MeshInstance3D
var waypoint_label: Label3D
var waypoint_arrow: Label3D
var discovered := false
var waypoint_active := false
var pulse_time := 0.0
var interact_pulse_timer := 0.0
var highlight_timer := 0.0


func _ready() -> void:
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		player_inside = true
		if zone_id == "demo_arena" and body.has_method("trigger_boss_zone_zoom"):
			body.trigger_boss_zone_zoom()
		if not discovered:
			discovered = true
			WebBridgeRef.post_event({
				"type": "DISCOVER_DISTRICT",
				"districtId": zone_id,
				"districtName": zone_name,
				"description": zone_description
			})


func _on_body_exited(body: Node) -> void:
	if body is CharacterBody3D:
		player_inside = false


func can_interact(_player_position: Vector3) -> bool:
	return player_inside


func get_prompt_text() -> String:
	if waypoint_active and zone_id == "client_district":
		return "Press E to start your first contract"
	if waypoint_active and zone_id == "training_center":
		return "Press E to train for bigger contracts"
	return "Press E to enter %s" % zone_name


func interact() -> void:
	trigger_interaction_pulse()
	WebBridgeRef.post_event({
		"type": "ENTER_DISTRICT",
		"districtId": zone_id,
		"districtName": zone_name,
		"districtType": zone_type,
		"missionId": mission_id,
		"description": zone_description
	})


func set_highlighted(active: bool) -> void:
	if glow_mesh == null:
		return
	glow_mesh.scale = Vector3.ONE * (1.22 if active or waypoint_active else 1.0)
	glow_mesh.visible = true
	if label_node != null:
		label_node.modulate = Color("ffffff") if active else Color("d7ecff")


func set_waypoint(active: bool) -> void:
	waypoint_active = active
	if waypoint_beam != null:
		waypoint_beam.visible = active
	if waypoint_label != null:
		waypoint_label.visible = active
	if waypoint_arrow != null:
		waypoint_arrow.visible = active


func trigger_interaction_pulse() -> void:
	interact_pulse_timer = 0.34


func trigger_special_highlight() -> void:
	highlight_timer = 2.4


func _process(delta: float) -> void:
	pulse_time += delta
	interact_pulse_timer = max(0.0, interact_pulse_timer - delta)
	highlight_timer = max(0.0, highlight_timer - delta)
	if waypoint_arrow != null and waypoint_arrow.visible:
		waypoint_arrow.position.y = 9.9 + sin(pulse_time * 2.6) * 0.26
	if waypoint_label != null and waypoint_label.visible:
		waypoint_label.position.y = 8.4 + sin(pulse_time * 1.9) * 0.12
	if glow_mesh != null and waypoint_active:
		var pulse := 1.0 + (sin(pulse_time * 3.0) + 1.0) * 0.08
		glow_mesh.scale = Vector3.ONE * pulse
	if glow_mesh != null and interact_pulse_timer > 0.0:
		var interact_pulse := 1.1 + sin((1.0 - interact_pulse_timer / 0.34) * PI) * 0.24
		glow_mesh.scale = Vector3.ONE * interact_pulse
	if glow_mesh != null and highlight_timer > 0.0:
		var material := glow_mesh.material_override as StandardMaterial3D
		if material != null:
			material.emission_energy_multiplier = 0.42 + sin(pulse_time * 5.2) * 0.1 + 0.28
	elif glow_mesh != null:
		var fallback_material := glow_mesh.material_override as StandardMaterial3D
		if fallback_material != null:
			fallback_material.emission_energy_multiplier = 0.42
	if waypoint_beam != null and waypoint_beam.visible:
		var beam_material := waypoint_beam.material_override as StandardMaterial3D
		if beam_material != null:
			beam_material.emission_energy_multiplier = 0.24 + (sin(pulse_time * 2.8) + 1.0) * 0.16
