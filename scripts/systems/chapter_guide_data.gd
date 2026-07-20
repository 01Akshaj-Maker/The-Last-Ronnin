@tool
class_name ChapterGuideData
extends Resource

## A chapter's player-guidance content (Bible §4 clarity, kept in the moody register of §6).
## All authored as data, per chapter, so a new chapter carries its own guidance with no code
## change (§9): the opening thoughts, a faint controls hint, and the ordered objective steps.
##
## `onboarding` are the samurai's own thoughts, shown once as the chapter opens (leave empty
## for later chapters that need no re-teaching). `controls_hint` is the faint move/interact
## line that fades out once the player first acts. `objectives` is the ordered goal list.

@export var onboarding: PackedStringArray = PackedStringArray()
@export var controls_hint: String = ""
@export var objectives: Array[ObjectiveStep] = []
