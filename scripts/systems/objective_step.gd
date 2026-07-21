@tool
class_name ObjectiveStep
extends Resource

## One line of the player's current goal (the guidance layer, Bible §4 "arrive -> explore ->
## ... -> move on"). Pure data: the text shown, and the event that completes this step and
## advances to the next. Authoring a chapter's guidance is editing these in a .tres — no code.
##
## `advance_on` is a small named beat the chapter reports (e.g. "talked"); leave it empty for
## the final step, which simply stands until the chapter ends.
##
## `requires` is the "gather" form: list several beats (e.g. every villager to hear) and the
## step only completes once ALL of them have been reported, in any order. The guide shows a
## "(2 of 4)" tally as they come in. Leave it empty to use the single-beat `advance_on`.

@export_multiline var text: String = ""
@export var advance_on: String = ""
@export var requires: PackedStringArray = PackedStringArray()
