extends Area3D
class_name CollectibleToken

const WebBridgeRef = preload("res://scripts/WebBridge.gd")

@export var item_id := "knowledge_token"
@export var item_name := "Knowledge Token"
@export var reward_xp := 5
@export var hint := "Explore the city to find more hidden opportunities."

var collected := false
var mesh_node: MeshInstance3D
var pulse_time := 0.0
var base_position := Vector3.ZERO


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	base_position = position


func _process(delta: float) -> void:
	pulse_time += delta
	if mesh_node != null:
		mesh_node.rotation.y += delta * 1.6
		mesh_node.position.y = 0.75 + sin(pulse_time * 2.4) * 0.12


func _on_body_entered(body: Node) -> void:
	if collected:
		return
	if body is CharacterBody3D:
		collected = true
		WebBridgeRef.post_event({
			"type": "COLLECT_TOKEN",
			"itemId": item_id,
			"itemName": item_name,
			"rewardXP": reward_xp,
			"hint": hint
		})
		queue_free()
