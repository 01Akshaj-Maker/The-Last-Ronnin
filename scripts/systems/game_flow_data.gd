@tool
class_name GameFlowData
extends Resource

## The whole journey as data (Bible §2): an intro, an ORDERED list of chapters, and the grave
## as the fixed final destination. The order never branches — choices change reflection, not
## this sequence. Edit res://data/flow/game_flow.tres to add/reorder chapters; the GameFlow
## director reads it and needs no code changes (§9).

@export_file("*.tscn") var intro_scene: String = "res://scenes/flow/Intro.tscn"
@export_multiline var intro_title: String = ""
@export_multiline var intro_body: String = ""

## Played in order. After the last one, the journey always ends at `ending_scene`.
@export var chapters: Array[ChapterEntry] = []

@export_file("*.tscn") var ending_scene: String = "res://scenes/ending/Ending.tscn"
