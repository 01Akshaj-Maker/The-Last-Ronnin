extends Area2D

## A chapter's completion trigger (Bible §4, "climax -> move on"). When the player walks into
## it, the chapter is done and the director advances (to the next chapter, or the grave after
## the last). Drop one into any chapter scene at its exit — adding a chapter is that plus a
## GameFlowData entry, no code (§9).

## Optional per-chapter override for the exit signpost text (§4 "clear exit"). Leave empty to
## keep the scene's default label — set it when a chapter needs its own wording (e.g. a pass).
@export var sign_text: String = ""

## When true, the exit stays LOCKED until the chapter's guide reports it is ready to leave
## (all objectives finished): the road is barred by a solid gate and walking in early just
## draws a quiet nudge. The gate opens the moment the chapter is heard out. Off by default so
## chapters that don't gate the road behave exactly as before (§9).
@export var require_ready: bool = false

@onready var _hint: Label = $Hint
@onready var _gate_collision: CollisionShape2D = $Gate/Collision
@onready var _gate_visual: ColorRect = $Gate/GateVisual

var _gate_open: bool = false


func _ready() -> void:
	if sign_text != "" and _hint != null:
		_hint.text = sign_text
	body_entered.connect(_on_body_entered)
	# A gate always seals the gap so the player can never walk out into the void. An ungated
	# chapter opens it at once (road's open); a gated one keeps it shut until it's ready.
	if require_ready:
		_close_gate()
	else:
		_open_gate(true)


func _process(_delta: float) -> void:
	# The way north opens the moment a gated chapter has been fully heard out.
	if require_ready and not _gate_open and _guide_ready():
		_open_gate(false)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if require_ready and not _guide_ready():
		var guide: Node = get_tree().get_first_node_in_group("chapter_guide")
		if guide != null and guide.has_method("flash_notice"):
			guide.flash_notice("Not yet. There are still voices here you have not heard.")
		return
	_leave(body)


func _leave(body: Node) -> void:
	# Stop the player the instant we commit, so they can't drift out past the edge while the
	# screen fades to the next chapter.
	var player: Node = body if body.has_method("set_movement_enabled") else get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(false)
	# One-shot; don't fire again mid-transition. Deferred: Godot blocks changing monitoring
	# directly inside a body_entered callback.
	set_deferred("monitoring", false)
	GameFlow.advance_chapter()


func _open_gate(instant: bool) -> void:
	_gate_open = true
	_gate_collision.set_deferred("disabled", true)
	if instant:
		_gate_visual.visible = false
		return
	var tween: Tween = create_tween()
	tween.tween_property(_gate_visual, "modulate:a", 0.0, 0.7)
	tween.tween_callback(func() -> void: _gate_visual.visible = false)


func _close_gate() -> void:
	_gate_open = false
	_gate_collision.set_deferred("disabled", false)
	_gate_visual.visible = true
	_gate_visual.modulate.a = 1.0


func _guide_ready() -> bool:
	var guide: Node = get_tree().get_first_node_in_group("chapter_guide")
	if guide == null or not guide.has_method("is_ready_to_leave"):
		return true
	return guide.is_ready_to_leave()
