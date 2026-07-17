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


## The line to show right now: the first matching reflected-world variant, else the default
## body. Evaluated fresh each time the conversation opens.
func get_active_body() -> String:
	for variant in variants:
		if variant != null and variant.is_active():
			return variant.body
	return body
