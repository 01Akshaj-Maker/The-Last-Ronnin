extends Area2D

## A chapter's completion trigger (Bible §4, "climax -> move on"). When the player walks into
## it, the chapter is done and the director advances (to the next chapter, or the grave after
## the last). Drop one into any chapter scene at its exit — adding a chapter is that plus a
## GameFlowData entry, no code (§9).

## Optional per-chapter override for the exit signpost text (§4 "clear exit"). Leave empty to
## keep the scene's default label — set it when a chapter needs its own wording (e.g. a pass).
@export var sign_text: String = ""

## When true, the exit stays locked until the chapter's guide reports it is ready to leave
## (all objectives finished) — walking in early just draws a quiet nudge instead of advancing.
## Off by default so chapters that don't gate the road behave exactly as before (§9).
@export var require_ready: bool = false

@onready var _hint: Label = $Hint


func _ready() -> void:
	if sign_text != "" and _hint != null:
		_hint.text = sign_text
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if require_ready and not _guide_ready():
		var guide: Node = get_tree().get_first_node_in_group("chapter_guide")
		if guide != null and guide.has_method("flash_notice"):
			guide.flash_notice("Not yet. There are still voices here you have not heard.")
		return
	# One-shot; don't fire again mid-transition. Must be deferred: Godot blocks changing
	# monitoring directly inside a body_entered callback.
	set_deferred("monitoring", false)
	GameFlow.advance_chapter()


func _guide_ready() -> bool:
	var guide: Node = get_tree().get_first_node_in_group("chapter_guide")
	if guide == null or not guide.has_method("is_ready_to_leave"):
		return true
	return guide.is_ready_to_leave()
