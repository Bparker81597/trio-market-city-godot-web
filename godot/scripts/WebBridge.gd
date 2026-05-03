extends RefCounted
class_name WebBridge


static func post_event(payload: Dictionary) -> void:
	if not OS.has_feature("web"):
		return
	var json_payload := JSON.stringify(payload)
	JavaScriptBridge.eval("window.parent?.postMessage(%s, '*');" % json_payload, true)


static func open_mission(payload: Dictionary) -> void:
	post_event(payload)


static func notify_ready() -> void:
	post_event({"type": "GODOT_READY"})
