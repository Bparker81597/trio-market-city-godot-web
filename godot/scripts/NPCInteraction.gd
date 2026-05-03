extends Area3D
class_name NPCInteraction

const WebBridgeRef = preload("res://scripts/WebBridge.gd")

@export var npc_id := "board_coach"
@export var npc_name := "Board Coach"
@export var npc_role := "Guide"
@export var mission_id := "reflection_planning"
@export var dialog_preview := "Let's make your first move."
@export var mission_title := "Board Coach Guidance"
@export var mission_objective := "Walk to the Client District to claim your first opportunity."
@export var reward_money := 0
@export var reward_xp := 10
@export var reward_reputation := 0
@export var reward_public_fund := 0
@export var mission_skill := "Strategy"

var player_inside := false
var glow_mesh: MeshInstance3D
var label_node: Label3D
var discovered := false
var pulse_time := 0.0
var interact_pulse_timer := 0.0


func _ready() -> void:
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		player_inside = true
		if not discovered:
			discovered = true
			WebBridgeRef.post_event({
				"type": "DISCOVER_NPC",
				"npcId": npc_id,
				"npcName": npc_name
			})


func _on_body_exited(body: Node) -> void:
	if body is CharacterBody3D:
		player_inside = false


func can_interact(_player_position: Vector3) -> bool:
	return player_inside


func get_prompt_text() -> String:
	return "Press E to talk to %s" % npc_name


func interact() -> void:
	interact_pulse_timer = 0.34
	WebBridgeRef.post_event({
		"type": "OPEN_MISSION",
		"sourceType": "npc",
		"sourceId": npc_id,
		"sourceName": npc_name,
		"npcId": npc_id,
		"npcName": npc_name,
		"npcRole": npc_role,
		"missionId": mission_id,
		"dialogPreview": dialog_preview,
		"title": mission_title,
		"objective": mission_objective,
		"rewardMoney": reward_money,
		"rewardXP": reward_xp,
		"rewardReputation": reward_reputation,
		"publicFund": reward_public_fund,
		"skill": mission_skill,
		"reward": _build_reward_label()
	})


func set_highlighted(active: bool) -> void:
	if glow_mesh != null:
		glow_mesh.scale = Vector3.ONE * (1.16 if active else 1.0)
	if label_node != null:
		label_node.modulate = Color("ffffff") if active else Color("d7ecff")


func _process(delta: float) -> void:
	pulse_time += delta
	interact_pulse_timer = max(0.0, interact_pulse_timer - delta)
	if glow_mesh != null:
		glow_mesh.position.y = 0.05 + sin(pulse_time * 2.2) * 0.02
		if interact_pulse_timer > 0.0:
			var pulse := 1.12 + sin((1.0 - interact_pulse_timer / 0.34) * PI) * 0.22
			glow_mesh.scale = Vector3.ONE * pulse
	if label_node != null:
		label_node.position.y = 2.3 + sin(pulse_time * 1.9) * 0.04


func _build_reward_label() -> String:
	var parts: Array[String] = []
	if reward_money != 0:
		parts.append("$%d" % reward_money)
	if reward_xp != 0:
		parts.append("%d XP" % reward_xp)
	if reward_reputation != 0:
		parts.append("%d Reputation" % reward_reputation)
	if reward_public_fund != 0:
		parts.append("Public Fund +$%d" % reward_public_fund)
	return " + ".join(parts)
