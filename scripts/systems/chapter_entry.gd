@tool
class_name ChapterEntry
extends Resource

## One chapter in the fixed journey (Bible §2 — the order never branches). Pure data: a scene
## to load and the travel line shown when the player leaves it. Adding a chapter to the game is
## adding one of these to the GameFlowData list + giving that chapter scene an exit trigger —
## no code (§9).

## Scene loaded for this chapter, e.g. "res://scenes/world/Main.tscn".
@export_file("*.tscn") var scene_path: String = ""
## Interstitial "travel" line shown as the player leaves this chapter, e.g.
## "He traveled on. Days passed." Leave empty for no card.
@export_multiline var travel_text: String = ""
