extends Node2D

## Composition root for the playable area (Bible §9). Wires interactables (NPCs and props) to
## the dialogue box and the player so none of them need to know about each other, routes a
## picked choice's data-defined effects into the Identity system (§3), and drives the chapter's
## guidance overlay (§4 clarity) as the player acts.
##
## Adding an interactable is a localized change: drop it under the scene, give it a dialogue
## resource, and put it in the "interactable" group — this script auto-connects it. Each
## interactable carries a `guide_event` (§4): on close it reports that beat to the chapter
## guide, which advances the objective if it matches. Actors is Y-sorted so characters render
## in the correct front/back order.

@onready var _player: CharacterBody2D = $Actors/Player
@onready var _dialogue_box: CanvasLayer = $DialogueUI
@onready var _guide: Node = get_node_or_null("ChapterGuide")

var _pending_event: String = ""


func _ready() -> void:
	_dialogue_box.closed.connect(_on_dialogue_closed)
	_dialogue_box.cancelled.connect(_on_dialogue_cancelled)
	_dialogue_box.choice_selected.connect(_on_choice_selected)
	for node in get_tree().get_nodes_in_group("interactable"):
		node.interacted.connect(_on_interactable_interacted.bind(node))


func _on_interactable_interacted(dialogue: DialogueData, node: Node) -> void:
	_player.set_movement_enabled(false)
	_set_interactables_enabled(false)
	_dialogue_box.open(dialogue)
	# Remember which beat this interactable reports, so on close we both advance the guide and
	# record it globally (Identity) for ordering-aware dialogue variants (§3).
	_pending_event = node.guide_event
	if _guide != null:
		_guide.mark_interacted()


func _on_choice_selected(_index: int, choice: DialogueChoice) -> void:
	Identity.apply_effects(choice.effects)


func _on_dialogue_closed() -> void:
	_player.set_movement_enabled(true)
	_set_interactables_enabled(true)
	if _pending_event != "":
		Identity.mark_event(_pending_event)
		if _guide != null:
			_guide.report_event(_pending_event)
		_pending_event = ""


## The player backed out of a choice with E. Hand control back, but record nothing — no beat,
## no effect — so the conversation still counts as unfinished and can be had for real later.
func _on_dialogue_cancelled() -> void:
	_player.set_movement_enabled(true)
	_set_interactables_enabled(true)
	_pending_event = ""


func _set_interactables_enabled(enabled: bool) -> void:
	for node in get_tree().get_nodes_in_group("interactable"):
		node.set_enabled(enabled)
