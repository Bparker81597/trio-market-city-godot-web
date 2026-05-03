extends Node3D

const WebBridgeRef = preload("res://scripts/WebBridge.gd")

@export var npc_id := "npc_agency_rival"
@export var npc_name := "NPC Agency Rival"
@export var mission_id := "boss_pitch_battle"

var player_near := false
var last_interact_frame := -1

@onready var label: Label3D = $Label3D
@onready var area: Area3D = $Area3D
@onready var mesh_root: Node3D = $MeshyCharacter


func _ready() -> void:
	add_to_group("interactable")
	label.text = npc_name
	area.body_entered.connect(_on_area_3d_body_entered)
	area.body_exited.connect(_on_area_3d_body_exited)


func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("interact"):
		_open_mission()


func can_interact(_player_position: Vector3) -> bool:
	return player_near


func get_prompt_text() -> String:
	return "Press E: " + npc_name


func interact() -> void:
	_open_mission()


func set_highlighted(active: bool) -> void:
	label.modulate = Color("ffffff") if active else Color("d7ecff")
	mesh_root.scale = Vector3.ONE * (0.022 if active else 0.02)


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


func _on_area_3d_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_near = true
		label.text = "Press E: " + npc_name


func _on_area_3d_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_near = false
		label.text = npc_name
