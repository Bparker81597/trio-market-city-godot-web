extends Node3D
class_name CityBuilder

const DistrictZoneScript = preload("res://scripts/DistrictZone.gd")
const NPCInteractionScript = preload("res://scripts/NPCInteraction.gd")
const CollectibleTokenScript = preload("res://scripts/CollectibleToken.gd")
const AgencyRivalScene = preload("res://scenes/NPC_AgencyRival.tscn")
const HOUSE_A = preload("res://assets/kenney_modular_buildings/building-sample-house-a.glb")
const HOUSE_B = preload("res://assets/kenney_modular_buildings/building-sample-house-b.glb")
const HOUSE_C = preload("res://assets/kenney_modular_buildings/building-sample-house-c.glb")
const TOWER_A = preload("res://assets/kenney_modular_buildings/building-sample-tower-a.glb")
const TOWER_B = preload("res://assets/kenney_modular_buildings/building-sample-tower-b.glb")
const TOWER_C = preload("res://assets/kenney_modular_buildings/building-sample-tower-c.glb")
const TOWER_D = preload("res://assets/kenney_modular_buildings/building-sample-tower-d.glb")

const DISTRICTS := [
	{"id": "home_base", "name": "Home Base", "type": "hub", "mission": "reflection_planning", "position": Vector3(-18, 0, 14), "color": Color("5acbff"), "footprint": 5.8},
	{"id": "training_center", "name": "Training Center", "type": "training", "mission": "skill_training_intro", "position": Vector3(-4, 0, -17), "color": Color("9c7bff"), "footprint": 5.0},
	{"id": "tool_market", "name": "Tool Market", "type": "market", "mission": "tool_market_intro", "position": Vector3(-16, 0, -8), "color": Color("55a3ff"), "footprint": 5.1},
	{"id": "client_district", "name": "Client District", "type": "client", "mission": "youth_forward_gr", "position": Vector3(18, 0, -2), "color": Color("78d96f"), "footprint": 5.4},
	{"id": "city_hall", "name": "City Hall", "type": "civic", "mission": "public_fund_intro", "position": Vector3(8, 0, -14), "color": Color("ffd166"), "footprint": 5.4},
	{"id": "networking_plaza", "name": "Networking Hub", "type": "social", "mission": "networking_intro", "position": Vector3(18, 0, 10), "color": Color("9d76ff"), "footprint": 5.4},
	{"id": "opportunity_plaza", "name": "Opportunity Plaza", "type": "opportunity", "mission": "opportunity_board_intro", "position": Vector3(0, 0, 0), "color": Color("ffb14d"), "footprint": 6.4},
	{"id": "innovation_lab", "name": "Innovation Lab", "type": "innovation", "mission": "innovation_lab_intro", "position": Vector3(-2, 0, 18), "color": Color("4ee9d5"), "footprint": 5.0},
	{"id": "demo_arena", "name": "Demo Arena", "type": "boss", "mission": "boss_pitch_battle", "position": Vector3(18, 0, 18), "color": Color("ff6e8d"), "footprint": 5.8},
	{"id": "market_street", "name": "Market Street", "type": "street", "mission": "market_street_intro", "position": Vector3(-12, 0, 4), "color": Color("8be0ff"), "footprint": 4.6}
]

const NPCS := [
	{"id": "board_coach", "name": "Board Coach", "role": "Guide", "district": "home_base", "offset": Vector3(2.8, 0, 1.2), "mission_id": "reflection_planning", "dialog_preview": "Walk to the Client District to claim your first opportunity.", "title": "Board Coach Guidance", "objective": "Walk to the Client District to claim your first opportunity.", "reward_money": 0, "reward_xp": 10, "reward_reputation": 0, "public_fund": 0, "skill": "Strategy"},
	{"id": "youth_director", "name": "Youth Program Director", "role": "Client", "district": "client_district", "offset": Vector3(-2.0, 0, 1.2), "mission_id": "youth_forward_gr", "dialog_preview": "Our program needs more students, but families do not fully trust the current outreach.", "title": "Youth Forward GR", "objective": "Build a parent-friendly enrollment solution.", "reward_money": 500, "reward_xp": 25, "reward_reputation": 10, "public_fund": 50, "skill": "Communication + AI Prompting"},
	{"id": "web_mentor", "name": "Web Mentor", "role": "Mentor", "district": "training_center", "offset": Vector3(1.8, 0, 1.0), "mission_id": "skill_training_intro", "dialog_preview": "Strong prompts and research will sharpen your next pitch.", "title": "Training Center", "objective": "Upgrade your prompting and research before you pitch live clients.", "reward_money": 0, "reward_xp": 20, "reward_reputation": 0, "public_fund": 0, "skill": "AI Prompting + Research"},
	{"id": "design_vendor", "name": "Design Vendor", "role": "Seller", "district": "tool_market", "offset": Vector3(-1.8, 0, 0.8), "mission_id": "tool_market_intro", "dialog_preview": "The right tools help you ship faster and look more credible.", "title": "Tool Market", "objective": "Buy a Website Builder or Design Studio to improve delivery quality.", "reward_money": -120, "reward_xp": 0, "reward_reputation": 0, "public_fund": 0, "skill": "Strategy + Production"},
	{"id": "city_hall_agent", "name": "City Hall Agent", "role": "Civic", "district": "city_hall", "offset": Vector3(1.8, 0, -1.0), "mission_id": "public_fund_intro", "dialog_preview": "Public fund growth unlocks new city-backed opportunities.", "title": "City Hall", "objective": "Review taxes, public fund growth, and city-backed opportunity unlocks.", "reward_money": 0, "reward_xp": 12, "reward_reputation": 0, "public_fund": 0, "skill": "Systems Thinking"}
]

@onready var ground_root: Node3D = $CityGround
@onready var districts_root: Node3D = $Districts
@onready var buildings_root: Node3D = $Buildings
@onready var npcs_root: Node3D = $NPCs
@onready var zones_root: Node3D = $InteractionZones
@onready var props_root: Node3D = $Props

var district_lookup: Dictionary = {}
var active_waypoint_id := "client_district"
var guidance_markers: Array[MeshInstance3D] = []
var ambient_npcs: Array[Node3D] = []
var arena_pulse_meshes: Array[MeshInstance3D] = []


func _ready() -> void:
	_build_city_ground()
	_build_plaza_paths()
	for district in DISTRICTS:
		_build_district(district)
	_build_props()
	_build_npcs()
	_build_special_npcs()
	_build_guidance_markers()
	_build_collectibles()
	_build_ambient_npcs()


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	for index in range(ambient_npcs.size()):
		var npc := ambient_npcs[index]
		npc.position.y = 0.06 + sin(time * 1.6 + index) * 0.06
		npc.rotation.y = sin(time * 0.6 + index) * 0.24
	for arena_mesh in arena_pulse_meshes:
		if arena_mesh == null:
			continue
		var pulse := 1.0 + 0.035 * sin(time * 2.1)
		arena_mesh.scale = Vector3(pulse, 1.0, pulse)
		var material := arena_mesh.material_override as StandardMaterial3D
		if material != null:
			material.emission_energy_multiplier = 0.42 + (sin(time * 2.4) + 1.0) * 0.18


func _build_city_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(84, 84)
	ground.mesh = plane
	ground.material_override = _flat_material(Color("dceff8"))
	ground.rotate_x(deg_to_rad(-90))
	ground_root.add_child(ground)

	var ground_body := StaticBody3D.new()
	ground_body.name = "GroundBody"
	ground_root.add_child(ground_body)

	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(84, 1.0, 84)
	ground_collision.shape = ground_shape
	ground_collision.position = Vector3(0, -0.5, 0)
	ground_body.add_child(ground_collision)

	var lawn := MeshInstance3D.new()
	var lawn_plane := PlaneMesh.new()
	lawn_plane.size = Vector2(62, 62)
	lawn.mesh = lawn_plane
	lawn.position = Vector3(0, 0.02, 0)
	lawn.rotate_x(deg_to_rad(-90))
	lawn.material_override = _flat_material(Color("cbe8d3"))
	ground_root.add_child(lawn)

func _build_plaza_paths() -> void:
	var center_plaza := MeshInstance3D.new()
	var center_mesh := CylinderMesh.new()
	center_mesh.top_radius = 8.8
	center_mesh.bottom_radius = 9.2
	center_mesh.height = 0.18
	center_plaza.mesh = center_mesh
	center_plaza.position = Vector3(0, 0.12, 0)
	center_plaza.material_override = _flat_material(Color("f5f7fb"))
	props_root.add_child(center_plaza)

	var center_ring := MeshInstance3D.new()
	var center_ring_mesh := CylinderMesh.new()
	center_ring_mesh.top_radius = 5.8
	center_ring_mesh.bottom_radius = 6.0
	center_ring_mesh.height = 0.12
	center_ring.mesh = center_ring_mesh
	center_ring.position = Vector3(0, 0.2, 0)
	center_ring.material_override = _emissive_material(Color("59d7ff"), 0.28)
	props_root.add_child(center_ring)

	var path_specs := [
		{"pos": Vector3(-8, 0.05, -8), "size": Vector3(16, 0.08, 4.8), "rot": -35.0},
		{"pos": Vector3(8, 0.05, -8), "size": Vector3(16, 0.08, 4.8), "rot": 35.0},
		{"pos": Vector3(11, 0.05, 6), "size": Vector3(18, 0.08, 4.8), "rot": 22.0},
		{"pos": Vector3(-8, 0.05, 12), "size": Vector3(18, 0.08, 4.8), "rot": -18.0},
		{"pos": Vector3(-14, 0.05, 2), "size": Vector3(14, 0.08, 4.8), "rot": 10.0},
		{"pos": Vector3(0, 0.05, 13), "size": Vector3(12, 0.08, 4.8), "rot": 0.0}
	]

	for spec in path_specs:
		var walk := MeshInstance3D.new()
		var walk_mesh := BoxMesh.new()
		walk_mesh.size = spec["size"]
		walk.mesh = walk_mesh
		walk.position = spec["pos"]
		walk.rotation_degrees.y = spec["rot"]
		walk.material_override = _flat_material(Color("f1f4f8"))
		props_root.add_child(walk)

		var edge := MeshInstance3D.new()
		var edge_mesh := BoxMesh.new()
		edge_mesh.size = spec["size"] + Vector3(0.8, -0.02, 0.8)
		edge.mesh = edge_mesh
		edge.position = spec["pos"] + Vector3(0, -0.04, 0)
		edge.rotation_degrees.y = spec["rot"]
		edge.material_override = _flat_material(Color("d5dbe8"))
		props_root.add_child(edge)

	_build_first_mission_path()
	_build_center_hologram()


func _build_first_mission_path() -> void:
	var marker_positions := [
		Vector3(-12.0, 0.12, 9.6),
		Vector3(-6.2, 0.12, 6.6),
		Vector3(0.4, 0.12, 3.7),
		Vector3(7.6, 0.12, 1.2),
		Vector3(14.5, 0.12, -0.7)
	]

	for marker_pos in marker_positions:
		var marker := MeshInstance3D.new()
		var marker_mesh := CylinderMesh.new()
		marker_mesh.top_radius = 0.48
		marker_mesh.bottom_radius = 0.64
		marker_mesh.height = 0.14
		marker.mesh = marker_mesh
		marker.position = marker_pos
		marker.material_override = _emissive_material(Color("7bff9c"), 0.35)
		props_root.add_child(marker)


func _build_center_hologram() -> void:
	var holo_group := Node3D.new()
	holo_group.position = Vector3(0, 0.22, 0)
	props_root.add_child(holo_group)

	var platform := MeshInstance3D.new()
	var platform_mesh := CylinderMesh.new()
	platform_mesh.top_radius = 3.2
	platform_mesh.bottom_radius = 3.5
	platform_mesh.height = 0.5
	platform.mesh = platform_mesh
	platform.position = Vector3(0, 0.25, 0)
	platform.material_override = _flat_material(Color("6b96bc"))
	holo_group.add_child(platform)

	var beam := MeshInstance3D.new()
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 2.6
	beam_mesh.bottom_radius = 2.6
	beam_mesh.height = 3.6
	beam.mesh = beam_mesh
	beam.position = Vector3(0, 2.1, 0)
	beam.material_override = _emissive_material(Color("41d5ff"), 0.38)
	holo_group.add_child(beam)

	var label := Label3D.new()
	label.text = "OPPORTUNITIES\nAVAILABLE"
	label.font_size = 36
	label.position = Vector3(0, 2.6, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 10
	label.outline_modulate = Color(0.07, 0.18, 0.32, 0.9)
	label.modulate = Color("dffcff")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	holo_group.add_child(label)


func _build_district(data: Dictionary) -> void:
	var position: Vector3 = data["position"]
	var color: Color = data["color"]
	var district_id := String(data["id"])
	var footprint := float(data.get("footprint", 5.0))

	var district_group := Node3D.new()
	district_group.position = position
	district_group.name = district_id.capitalize()
	buildings_root.add_child(district_group)

	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = footprint
	base_mesh.bottom_radius = footprint + 0.45
	base_mesh.height = 0.4
	base.mesh = base_mesh
	base.position = Vector3(0, 0.2, 0)
	base.material_override = _flat_material(color.lightened(0.18))
	district_group.add_child(base)

	_build_district_landmark(district_group, district_id, color, footprint)

	var sign := Label3D.new()
	sign.text = data["name"]
	sign.font_size = 40
	sign.position = Vector3(0, 6.2, 0)
	sign.modulate = color.darkened(0.2)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.outline_size = 10
	sign.outline_modulate = Color(1, 1, 1, 0.95)
	sign.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	district_group.add_child(sign)

	var zone = DistrictZoneScript.new()
	zone.zone_id = data["id"]
	zone.zone_name = data["name"]
	zone.zone_type = data["type"]
	zone.mission_id = data["mission"]
	zone.zone_description = _district_description(district_id)
	zone.position = position
	zones_root.add_child(zone)

	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = footprint + 0.5
	shape.height = 2.2
	collision.shape = shape
	collision.position = Vector3(0, 1.1, 0)
	zone.add_child(collision)

	var glow := MeshInstance3D.new()
	var glow_mesh := CylinderMesh.new()
	glow_mesh.top_radius = footprint + 0.55
	glow_mesh.bottom_radius = footprint + 0.55
	glow_mesh.height = 0.1
	glow.mesh = glow_mesh
	glow.position = Vector3(0, 0.06, 0)
	glow.material_override = _emissive_material(color, 0.42)
	zone.add_child(glow)
	zone.glow_mesh = glow
	zone.label_node = sign
	zone.waypoint_beam = _build_waypoint_beam(zone, color, footprint)
	zone.waypoint_label = _build_waypoint_label(zone, data["name"])
	zone.waypoint_arrow = _build_waypoint_arrow(zone, color)
	district_lookup[district_id] = zone

	_build_district_props(position, color, district_id, footprint)


func _build_district_landmark(parent: Node3D, district_id: String, color: Color, footprint: float) -> void:
	if _build_kenney_landmark(parent, district_id):
		return

	match district_id:
		"opportunity_plaza":
			var ring := MeshInstance3D.new()
			var ring_mesh := CylinderMesh.new()
			ring_mesh.top_radius = 3.0
			ring_mesh.bottom_radius = 3.3
			ring_mesh.height = 2.8
			ring.mesh = ring_mesh
			ring.position = Vector3(0, 1.75, 0)
			ring.material_override = _emissive_material(color, 0.42)
			parent.add_child(ring)

			var kiosk := MeshInstance3D.new()
			var kiosk_mesh := BoxMesh.new()
			kiosk_mesh.size = Vector3(4.4, 2.2, 1.4)
			kiosk.mesh = kiosk_mesh
			kiosk.position = Vector3(0, 1.3, 0)
			kiosk.material_override = _emissive_material(color.darkened(0.12), 0.32)
			parent.add_child(kiosk)
		"city_hall":
			for offset in [-1.3, 0.0, 1.3]:
				var tower := MeshInstance3D.new()
				var tower_mesh := CylinderMesh.new()
				tower_mesh.top_radius = 1.0 if offset == 0.0 else 0.74
				tower_mesh.bottom_radius = 1.15 if offset == 0.0 else 0.88
				tower_mesh.height = 4.5 if offset == 0.0 else 3.7
				tower.mesh = tower_mesh
				tower.position = Vector3(offset, tower_mesh.height * 0.5 + 0.4, 0)
				tower.material_override = _flat_material(color)
				parent.add_child(tower)
		"client_district", "networking_plaza":
			for spec in [
				{"pos": Vector3(-1.8, 2.0, 0.4), "size": Vector3(2.2, 3.2, 2.2)},
				{"pos": Vector3(1.2, 2.4, -0.4), "size": Vector3(2.6, 4.0, 2.6)},
				{"pos": Vector3(0.0, 1.8, 1.7), "size": Vector3(1.9, 2.8, 1.9)}
			]:
				var tower := MeshInstance3D.new()
				var tower_mesh := BoxMesh.new()
				tower_mesh.size = spec["size"]
				tower.mesh = tower_mesh
				tower.position = spec["pos"]
				tower.material_override = _flat_material(color)
				parent.add_child(tower)
		"demo_arena":
			var podium := MeshInstance3D.new()
			var podium_mesh := CylinderMesh.new()
			podium_mesh.top_radius = 2.7
			podium_mesh.bottom_radius = 3.3
			podium_mesh.height = 1.4
			podium.mesh = podium_mesh
			podium.position = Vector3(0, 0.95, 0)
			podium.material_override = _flat_material(color)
			parent.add_child(podium)

			var crown := MeshInstance3D.new()
			var crown_mesh := BoxMesh.new()
			crown_mesh.size = Vector3(3.1, 2.8, 3.1)
			crown.mesh = crown_mesh
			crown.position = Vector3(0, 3.0, 0)
			crown.material_override = _flat_material(color.lightened(0.06))
			parent.add_child(crown)

			var platform := MeshInstance3D.new()
			var platform_mesh := CylinderMesh.new()
			platform_mesh.top_radius = 4.25
			platform_mesh.bottom_radius = 4.7
			platform_mesh.height = 0.18
			platform.mesh = platform_mesh
			platform.position = Vector3(0, 0.18, 0)
			platform.material_override = _emissive_material(color.lightened(0.08), 0.42)
			parent.add_child(platform)
			arena_pulse_meshes.append(platform)

			var platform_ring := MeshInstance3D.new()
			var platform_ring_mesh := CylinderMesh.new()
			platform_ring_mesh.top_radius = 5.1
			platform_ring_mesh.bottom_radius = 5.45
			platform_ring_mesh.height = 0.09
			platform_ring.mesh = platform_ring_mesh
			platform_ring.position = Vector3(0, 0.11, 0)
			platform_ring.material_override = _emissive_material(Color("73efff"), 0.58)
			parent.add_child(platform_ring)

			var boss_label := Label3D.new()
			boss_label.text = "Boss Challenge"
			boss_label.font_size = 30
			boss_label.position = Vector3(0, 6.2, 0)
			boss_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			boss_label.outline_size = 8
			boss_label.outline_modulate = Color(0.07, 0.08, 0.14, 0.92)
			boss_label.modulate = Color("fff1c6")
			boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			parent.add_child(boss_label)
		"training_center", "innovation_lab":
			var tower := MeshInstance3D.new()
			var tower_mesh := BoxMesh.new()
			tower_mesh.size = Vector3(3.8, 4.1, 3.8)
			tower.mesh = tower_mesh
			tower.position = Vector3(0, 2.45, 0)
			tower.material_override = _flat_material(color)
			parent.add_child(tower)


func _build_kenney_landmark(parent: Node3D, district_id: String) -> bool:
	var scene: PackedScene
	var scale_value := 1.0
	var y_offset := 0.42
	var rotation_value := 0.0

	match district_id:
		"home_base":
			scene = HOUSE_A
			scale_value = 1.35
		"training_center":
			scene = TOWER_A
			scale_value = 1.2
		"tool_market":
			scene = HOUSE_B
			scale_value = 1.2
		"client_district":
			scene = TOWER_B
			scale_value = 1.12
		"city_hall":
			scene = TOWER_C
			scale_value = 1.18
		"networking_plaza":
			scene = HOUSE_C
			scale_value = 1.2
		"demo_arena":
			scene = TOWER_D
			scale_value = 1.3
		"market_street":
			scene = HOUSE_B
			scale_value = 1.05
			rotation_value = 18.0
		_:
			return false

	var instance = scene.instantiate()
	if instance == null:
		return false
	instance.scale = Vector3.ONE * scale_value
	instance.position = Vector3(0, y_offset, 0)
	instance.rotation_degrees.y = rotation_value
	parent.add_child(instance)
	return true


func _build_district_props(position: Vector3, color: Color, district_id: String, footprint: float) -> void:
	var tree_specs := [
		{"offset": Vector3(-footprint + 1.0, 0, -footprint + 0.8), "scale": 0.9},
		{"offset": Vector3(footprint - 1.1, 0, -footprint + 1.0), "scale": 1.12},
		{"offset": Vector3(-footprint + 1.5, 0, footprint - 1.4), "scale": 0.78}
	]
	for tree_spec in tree_specs:
		var tree_offset: Vector3 = tree_spec["offset"]
		var tree_scale := float(tree_spec["scale"])
		var tree_trunk := MeshInstance3D.new()
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.18 * tree_scale
		trunk_mesh.bottom_radius = 0.22 * tree_scale
		trunk_mesh.height = 1.0 * tree_scale
		tree_trunk.mesh = trunk_mesh
		tree_trunk.position = position + tree_offset + Vector3(0, 0.5 * tree_scale, 0)
		tree_trunk.material_override = _flat_material(Color("8f6a4d"))
		props_root.add_child(tree_trunk)

		var tree_top := MeshInstance3D.new()
		var top_mesh := SphereMesh.new()
		top_mesh.radius = 0.82 * tree_scale
		tree_top.mesh = top_mesh
		tree_top.position = position + tree_offset + Vector3(0, 1.55 * tree_scale, 0)
		tree_top.material_override = _flat_material(Color("89d98b"))
		props_root.add_child(tree_top)

	for bench_offset in [Vector3(-2.4, 0, footprint - 1.2), Vector3(2.2, 0, footprint - 1.2)]:
		var bench := MeshInstance3D.new()
		var bench_mesh := BoxMesh.new()
		bench_mesh.size = Vector3(1.2, 0.24, 0.36)
		bench.mesh = bench_mesh
		bench.position = position + bench_offset + Vector3(0, 0.22, 0)
		bench.material_override = _flat_material(Color("cb9f6f"))
		props_root.add_child(bench)

	var laptop_stand := MeshInstance3D.new()
	var stand_mesh := BoxMesh.new()
	stand_mesh.size = Vector3(0.9, 0.7, 0.55)
	laptop_stand.mesh = stand_mesh
	laptop_stand.position = position + Vector3(0, 0.38, footprint - 0.7)
	laptop_stand.material_override = _flat_material(Color("7f93ad"))
	props_root.add_child(laptop_stand)

	var laptop_screen := MeshInstance3D.new()
	var screen_mesh := BoxMesh.new()
	screen_mesh.size = Vector3(0.76, 0.42, 0.06)
	laptop_screen.mesh = screen_mesh
	laptop_screen.position = position + Vector3(0, 0.88, footprint - 0.48)
	laptop_screen.rotation_degrees.x = -14.0
	laptop_screen.material_override = _emissive_material(color.lightened(0.1), 0.26)
	props_root.add_child(laptop_screen)

	var poster := MeshInstance3D.new()
	var poster_mesh := BoxMesh.new()
	poster_mesh.size = Vector3(0.18, 1.6, 1.1)
	poster.mesh = poster_mesh
	poster.position = position + Vector3(footprint - 0.9, 0.86, 0)
	poster.material_override = _emissive_material(color.lightened(0.14), 0.18)
	props_root.add_child(poster)

	_build_district_icon(position + Vector3(0, 0.5, -footprint + 1.0), color, district_id)


func _build_district_icon(position: Vector3, color: Color, district_id: String) -> void:
	var icon := MeshInstance3D.new()
	match district_id:
		"tool_market":
			var wrench := CylinderMesh.new()
			wrench.top_radius = 0.12
			wrench.bottom_radius = 0.12
			wrench.height = 1.4
			icon.mesh = wrench
		"city_hall":
			var hall := BoxMesh.new()
			hall.size = Vector3(1.2, 0.9, 0.8)
			icon.mesh = hall
		"demo_arena":
			var trophy := CylinderMesh.new()
			trophy.top_radius = 0.22
			trophy.bottom_radius = 0.42
			trophy.height = 1.2
			icon.mesh = trophy
		"training_center":
			var crystal := BoxMesh.new()
			crystal.size = Vector3(0.65, 1.3, 0.65)
			icon.mesh = crystal
		"client_district":
			var briefcase := BoxMesh.new()
			briefcase.size = Vector3(1.0, 0.72, 0.5)
			icon.mesh = briefcase
		_:
			var badge := SphereMesh.new()
			badge.radius = 0.42
			icon.mesh = badge
	icon.position = position + Vector3(0, 0.9, 0)
	icon.material_override = _emissive_material(color, 0.46)
	props_root.add_child(icon)


func _build_waypoint_beam(zone: DistrictZone, color: Color, footprint: float) -> MeshInstance3D:
	var beam := MeshInstance3D.new()
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.38
	beam_mesh.bottom_radius = 0.62
	beam_mesh.height = 8.0
	beam.mesh = beam_mesh
	beam.position = Vector3(0, 4.0, 0)
	beam.material_override = _emissive_material(color.lightened(0.18), 0.18)
	beam.visible = false
	zone.add_child(beam)
	return beam


func _build_waypoint_label(zone: DistrictZone, label_text: String) -> Label3D:
	var next_label := Label3D.new()
	next_label.text = "NEXT: %s" % label_text
	next_label.font_size = 28
	next_label.position = Vector3(0, 8.4, 0)
	next_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	next_label.outline_size = 8
	next_label.outline_modulate = Color(0.08, 0.18, 0.36, 0.94)
	next_label.modulate = Color("efffff")
	next_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_label.visible = false
	zone.add_child(next_label)
	return next_label


func _build_waypoint_arrow(zone: DistrictZone, color: Color) -> Label3D:
	var arrow := Label3D.new()
	arrow.text = "▼"
	arrow.font_size = 46
	arrow.position = Vector3(0, 9.9, 0)
	arrow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arrow.outline_size = 10
	arrow.outline_modulate = Color(1, 1, 1, 0.95)
	arrow.modulate = color.lightened(0.14)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.visible = false
	zone.add_child(arrow)
	return arrow


func _build_props() -> void:
	for light_pos in [Vector3(-8, 0, -8), Vector3(8, 0, -8), Vector3(12, 0, 6), Vector3(-10, 0, 12), Vector3(0, 0, 15)]:
		var pole := MeshInstance3D.new()
		var pole_mesh := CylinderMesh.new()
		pole_mesh.top_radius = 0.12
		pole_mesh.bottom_radius = 0.12
		pole_mesh.height = 3.2
		pole.mesh = pole_mesh
		pole.position = light_pos + Vector3(0, 1.6, 0)
		pole.material_override = _flat_material(Color("9fb3c8"))
		props_root.add_child(pole)

		var lamp := OmniLight3D.new()
		lamp.light_color = Color("fff4d1")
		lamp.light_energy = 0.95
		lamp.omni_range = 8.0
		lamp.position = light_pos + Vector3(0, 3.5, 0)
		props_root.add_child(lamp)

	for accent in [
		Vector3(-6, 0.02, -2),
		Vector3(6, 0.02, 2),
		Vector3(-3, 0.02, 8),
		Vector3(10, 0.02, -2)
	]:
		var planter := MeshInstance3D.new()
		var planter_mesh := CylinderMesh.new()
		planter_mesh.top_radius = 1.5
		planter_mesh.bottom_radius = 1.7
		planter_mesh.height = 0.35
		planter.mesh = planter_mesh
		planter.position = accent + Vector3(0, 0.18, 0)
		planter.material_override = _flat_material(Color("9cb5ca"))
		props_root.add_child(planter)

	for prop_pos in [Vector3(-14, 0.16, 10), Vector3(12, 0.16, 14), Vector3(6, 0.16, -12), Vector3(-10, 0.16, -12)]:
		var poster := MeshInstance3D.new()
		var poster_mesh := BoxMesh.new()
		poster_mesh.size = Vector3(0.24, 2.2, 1.2)
		poster.mesh = poster_mesh
		poster.position = prop_pos
		poster.material_override = _emissive_material(Color("7dd8ff"), 0.2)
		props_root.add_child(poster)

	var particle_cloud := GPUParticles3D.new()
	var particle_material := ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.spread = 12.0
	particle_material.initial_velocity_min = 0.15
	particle_material.initial_velocity_max = 0.35
	particle_material.gravity = Vector3.ZERO
	particle_material.scale_min = 0.08
	particle_material.scale_max = 0.16
	particle_cloud.process_material = particle_material
	particle_cloud.amount = 24
	particle_cloud.lifetime = 2.4
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.08
	particle_mesh.height = 0.16
	particle_cloud.draw_pass_1 = particle_mesh
	particle_cloud.position = Vector3(0, 1.6, 0)
	props_root.add_child(particle_cloud)


func set_waypoint_target(district_id: String) -> void:
	active_waypoint_id = district_id
	for key in district_lookup.keys():
		var zone: DistrictZone = district_lookup[key]
		zone.set_waypoint(String(key) == district_id)


func trigger_district_highlight(district_id: String) -> void:
	if not district_lookup.has(district_id):
		return
	var zone: DistrictZone = district_lookup[district_id]
	zone.trigger_special_highlight()


func update_player_guidance(player_position: Vector3) -> void:
	if not district_lookup.has(active_waypoint_id):
		for marker in guidance_markers:
			marker.visible = false
		return

	var target_zone: DistrictZone = district_lookup[active_waypoint_id]
	var target_position := target_zone.global_position + Vector3(0, 0.12, 0)
	var marker_count := guidance_markers.size()
	for index in range(marker_count):
		var marker := guidance_markers[index]
		var t := float(index + 1) / float(marker_count + 1)
		var marker_pos := player_position.lerp(target_position, t)
		marker.global_position = Vector3(marker_pos.x, 0.18 + sin((Time.get_ticks_msec() / 1000.0) * 3.0 + index) * 0.03, marker_pos.z)
		marker.visible = player_position.distance_to(target_position) > 3.0


func _build_guidance_markers() -> void:
	for _index in range(8):
		var marker := MeshInstance3D.new()
		var marker_mesh := CylinderMesh.new()
		marker_mesh.top_radius = 0.22
		marker_mesh.bottom_radius = 0.3
		marker_mesh.height = 0.12
		marker.mesh = marker_mesh
		marker.material_override = _emissive_material(Color("6aff9f"), 0.26)
		marker.visible = false
		props_root.add_child(marker)
		guidance_markers.append(marker)


func _district_description(district_id: String) -> String:
	match district_id:
		"home_base":
			return "Review goals, reflect, and plan your next move."
		"training_center":
			return "Improve skills here to unlock bigger contracts."
		"tool_market":
			return "Buy tools that increase your earning power."
		"client_district":
			return "Meet clients and claim your first contract here."
		"city_hall":
			return "Taxes build the public fund and unlock new RFPs."
		"networking_plaza":
			return "Build relationships that unlock stronger opportunities."
		"opportunity_plaza":
			return "Claim city opportunities and grow your portfolio."
		"innovation_lab":
			return "Test new ideas and improve your delivery system."
		"demo_arena":
			return "Showcase your strongest pitch and win bigger contracts."
		"market_street":
			return "Read city demand signals and find market trends."
		_:
			return "Explore this district to improve skills and opportunities."


func _build_npcs() -> void:
	for npc_data in NPCS:
		var district := DISTRICTS.filter(func(item): return item["id"] == npc_data["district"])
		if district.is_empty():
			continue
		var npc = NPCInteractionScript.new()
		npc.npc_id = npc_data["id"]
		npc.npc_name = npc_data["name"]
		npc.npc_role = npc_data["role"]
		npc.mission_id = npc_data["mission_id"]
		npc.dialog_preview = npc_data["dialog_preview"]
		npc.mission_title = npc_data["title"]
		npc.mission_objective = npc_data["objective"]
		npc.reward_money = npc_data["reward_money"]
		npc.reward_xp = npc_data["reward_xp"]
		npc.reward_reputation = npc_data["reward_reputation"]
		npc.reward_public_fund = npc_data["public_fund"]
		npc.mission_skill = npc_data["skill"]
		npc.position = district[0]["position"] + npc_data["offset"]
		npcs_root.add_child(npc)

		var collision := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 1.2
		collision.shape = shape
		collision.position = Vector3(0, 1.0, 0)
		npc.add_child(collision)

		var body := MeshInstance3D.new()
		var mesh := CapsuleMesh.new()
		mesh.radius = 0.28
		mesh.height = 0.9
		body.mesh = mesh
		body.position = Vector3(0, 0.92, 0)
		body.material_override = _flat_material(Color("6f8df8"))
		npc.add_child(body)

		var head := MeshInstance3D.new()
		var head_mesh := SphereMesh.new()
		head_mesh.radius = 0.22
		head.mesh = head_mesh
		head.position = Vector3(0, 1.56, 0)
		head.material_override = _flat_material(Color("ffd6be"))
		npc.add_child(head)

		var label := Label3D.new()
		label.text = npc_data["name"]
		label.font_size = 28
		label.position = Vector3(0, 2.3, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.outline_size = 8
		label.outline_modulate = Color(1, 1, 1, 0.95)
		label.modulate = Color("d7ecff")
		npc.add_child(label)

		var ring := MeshInstance3D.new()
		var ring_mesh := CylinderMesh.new()
		ring_mesh.top_radius = 0.92
		ring_mesh.bottom_radius = 0.92
		ring_mesh.height = 0.06
		ring.mesh = ring_mesh
		ring.position = Vector3(0, 0.05, 0)
		ring.material_override = _emissive_material(Color("7ae7ff"), 0.18)
		npc.add_child(ring)
		npc.glow_mesh = ring
		npc.label_node = label


func _build_special_npcs() -> void:
	var demo_district := DISTRICTS.filter(func(item): return item["id"] == "demo_arena")
	if demo_district.is_empty():
		return
	var rival := AgencyRivalScene.instantiate()
	if rival == null:
		return
	rival.position = demo_district[0]["position"] + Vector3(2.0, 0, -1.2)

	var rival_spotlight := SpotLight3D.new()
	rival_spotlight.name = "BossSpotlight"
	rival_spotlight.position = Vector3(0.0, 6.8, 0.4)
	rival_spotlight.rotation_degrees = Vector3(-88.0, 0.0, 0.0)
	rival_spotlight.light_energy = 4.2
	rival_spotlight.light_color = Color("ffe8b8")
	rival_spotlight.spot_range = 15.0
	rival_spotlight.spot_angle = 34.0
	rival_spotlight.spot_attenuation = 0.7
	rival.add_child(rival_spotlight)

	npcs_root.add_child(rival)


func _build_collectibles() -> void:
	var collectible_specs := [
		{"pos": Vector3(-8, 0.1, 8), "id": "knowledge_token", "name": "Knowledge Token", "hint": "Client work gets easier after you improve Communication in the Training Center."},
		{"pos": Vector3(10, 0.1, -7), "id": "funding_clue", "name": "Funding Clue", "hint": "City Hall explains how taxes grow the public fund and unlock new RFPs."},
		{"pos": Vector3(4, 0.1, 12), "id": "network_card", "name": "Networking Card", "hint": "Connections at Networking Hub can raise your reputation faster."}
	]

	for spec in collectible_specs:
		var token := CollectibleTokenScript.new()
		token.item_id = spec["id"]
		token.item_name = spec["name"]
		token.hint = spec["hint"]
		token.reward_xp = 5
		token.position = spec["pos"]
		props_root.add_child(token)

		var collision := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 0.65
		collision.shape = shape
		collision.position = Vector3(0, 0.7, 0)
		token.add_child(collision)

		var mesh := MeshInstance3D.new()
		var mesh_data := SphereMesh.new()
		mesh_data.radius = 0.24
		mesh_data.height = 0.48
		mesh.mesh = mesh_data
		mesh.position = Vector3(0, 0.75, 0)
		mesh.material_override = _emissive_material(Color("7bf2ff"), 0.4)
		token.add_child(mesh)
		token.mesh_node = mesh

		var halo := MeshInstance3D.new()
		var halo_mesh := CylinderMesh.new()
		halo_mesh.top_radius = 0.55
		halo_mesh.bottom_radius = 0.55
		halo_mesh.height = 0.05
		halo.mesh = halo_mesh
		halo.position = Vector3(0, 0.06, 0)
		halo.material_override = _emissive_material(Color("7bf2ff"), 0.18)
		token.add_child(halo)


func _build_ambient_npcs() -> void:
	var ambient_positions := [
		Vector3(-6, 0.06, 5),
		Vector3(3, 0.06, 9),
		Vector3(11, 0.06, 4),
		Vector3(-3, 0.06, -9)
	]

	for ambient_pos in ambient_positions:
		var ambient_root := Node3D.new()
		ambient_root.position = ambient_pos
		props_root.add_child(ambient_root)
		ambient_npcs.append(ambient_root)

		var body := MeshInstance3D.new()
		var body_mesh := CapsuleMesh.new()
		body_mesh.radius = 0.22
		body_mesh.height = 0.7
		body.mesh = body_mesh
		body.position = Vector3(0, 0.64, 0)
		body.material_override = _flat_material(Color("8ca0ff"))
		ambient_root.add_child(body)

		var head := MeshInstance3D.new()
		var head_mesh := SphereMesh.new()
		head_mesh.radius = 0.16
		head.mesh = head_mesh
		head.position = Vector3(0, 1.16, 0)
		head.material_override = _flat_material(Color("ffd7bf"))
		ambient_root.add_child(head)


func _flat_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material


func _emissive_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color.lightened(0.08)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	material.roughness = 0.62
	return material
