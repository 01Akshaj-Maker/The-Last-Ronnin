@tool
class_name ObjectiveStep
extends Resource

## One line of the player's current goal (the guidance layer, Bible §4 "arrive -> explore ->
## ... -> move on"). Pure data: the text shown, and the event that completes this step and
## advances to the next. Authoring a chapter's guidance is editing these in a .tres — no code.
##
## `advance_on` is a small named beat the chapter reports (e.g. "talked"); leave it empty for
## the final step, which simply stands until the chapter ends.

@export_multiline var text: String = ""
@export var advance_on: String = ""
