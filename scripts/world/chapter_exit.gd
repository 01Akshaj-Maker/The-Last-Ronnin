extends Area2D

## A chapter's completion trigger (Bible §4, "climax -> move on"). When the player walks into
## it, the chapter is done and the director advances (to the next chapter, or the grave after
## the last). Drop one into any chapter scene at its exit — adding a chapter is that plus a
## GameFlowData entry, no code (§9).

## Optional per-chapter override for the exit signpost text (§4 "clear exit"). Leave empty to
## keep the scene's default label — set it when a chapter needs its own wording (e.g. a pass).
@export var sign_text: String = ""

@onready var _hint: Label = $Hint


func _ready() -> void:
	if sign_text != "" and _hint != null:
		_hint.text = sign_text
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# One-shot; don't fire again mid-transition. Must be deferred: Godot blocks changing
		# monitoring directly inside a body_entered callback.
		set_deferred("monitoring", false)
		GameFlow.advance_chapter()
