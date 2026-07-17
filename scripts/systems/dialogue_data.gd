@tool
class_name DialogueData
extends Resource

## A single conversation, authored as data (Bible §9 "content as data").
##
## Point an NPC's `dialogue` slot at a .tres of this type to give it something to say.
## Author new conversations by creating new resource files in res://data/dialogue/ — no
## code changes required.

@export var speaker: String = ""
@export_multiline var body: String = ""
@export var choices: Array[DialogueChoice] = []
