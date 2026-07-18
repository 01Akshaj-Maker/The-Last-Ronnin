extends Node2D

## Composition root for the playable area (Bible §9). Wires NPCs to the dialogue box and
## the player so none of them need to know about each other, and routes a picked choice's
## data-defined effects into the Identity system (§3).
##
## Adding an NPC is a localized change: drop the Npc scene under Actors, give it a dialogue
## resource, and put it in the "npc" group — this script auto-connects it. Actors is Y-sorted
## so characters render in the correct front/back order.

@onready var _player: CharacterBody2D = $Actors/Player
@onready var _dialogue_box: CanvasLayer = $DialogueUI


func _ready() -> void:
	_dialogue_box.closed.connect(_on_dialogue_closed)
	_dialogue_box.choice_selected.connect(_on_choice_selected)
	for npc in get_tree().get_nodes_in_group("npc"):
		npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(dialogue: DialogueData) -> void:
	_player.set_movement_enabled(false)
	_set_npcs_enabled(false)
	_dialogue_box.open(dialogue)


func _on_choice_selected(_index: int, choice: DialogueChoice) -> void:
	Identity.apply_effects(choice.effects)


func _on_dialogue_closed() -> void:
	_player.set_movement_enabled(true)
	_set_npcs_enabled(true)


func _set_npcs_enabled(enabled: bool) -> void:
	for npc in get_tree().get_nodes_in_group("npc"):
		npc.set_enabled(enabled)
