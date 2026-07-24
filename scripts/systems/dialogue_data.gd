@tool
class_name DialogueData
extends Resource

## A single conversation, authored as data (Bible §9 "content as data").
##
## Point an NPC's `dialogue` slot at a .tres of this type to give it something to say. Author
## new conversations by creating new resource files in res://data/dialogue/ — no code changes.
##
## `body` is the default line. `variants` are optional reflected-world overrides (§3): the
## first one whose condition holds against the Identity counters replaces the body, so the
## same NPC frames itself differently depending on who the player has become.

@export var speaker: String = ""
@export_multiline var body: String = ""
@export var variants: Array[DialogueVariant] = []
@export var choices: Array[DialogueChoice] = []


## The first reflected-world variant whose condition currently holds, or null for the default.
## One source of truth so the body and the choices below always come from the SAME variant.
func get_active_variant() -> DialogueVariant:
	for variant in variants:
		if variant != null and variant.is_active():
			return variant
	return null


## The line to show right now: the active variant's body, else the default body. Evaluated
## fresh each time the conversation opens.
func get_active_body() -> String:
	var variant: DialogueVariant = get_active_variant()
	return variant.body if variant != null else body


## The choices to offer right now. A variant only replaces the base choices when it opts in
## (override_choices), so a reworded line can carry options that fit it — otherwise the base
## choices stand.
func get_active_choices() -> Array[DialogueChoice]:
	var variant: DialogueVariant = get_active_variant()
	if variant != null and variant.override_choices:
		return variant.choices
	return choices
