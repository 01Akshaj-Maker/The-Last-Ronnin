@tool
class_name DialogueVariant
extends Resource

## A conditional reflected-world line (Bible §3, "reflected world"). If its condition holds
## against the accumulated Identity counters, its `body` replaces the dialogue's default body
## — same scene slot, changed framing.
##
## Pure data: author a reaction by adding one of these to a DialogueData's `variants` and
## setting axis / comparator / threshold / body. No code (§9). The condition reads as
## "<axis> <comparator> <threshold>", e.g. Mercy >= 2.
##
## The optional event gates make a variant ordering-aware: `require_event` only lets it show
## once a named beat has happened, `forbid_event` only while it has NOT. This is how the same
## NPC can say something different before vs after the player has done a related thing (e.g. the
## widow before meeting the thief, the mother before the bell is found). For a purely order-based
## line with no counter test, set comparator to "any" so the counter check always passes.

@export var axis: String = "Honor"
## One of: "any" (always), ">=", "<=", ">", "<", "==", "!="
@export var comparator: String = ">="
@export var threshold: int = 1
## Only active once this beat has happened (empty = no such requirement).
@export var require_event: String = ""
## Only active while this beat has NOT happened yet (empty = no such block).
@export var forbid_event: String = ""
@export_multiline var body: String = ""
## When true, this variant also swaps the CHOICES the dialogue offers, so the options match its
## reworded line (e.g. a "you don't have the bell yet" line offering "where did you last hear
## it?" instead of "press the bell into her hands"). Leave off to keep the base choices. An
## empty `choices` array with this on makes the line a plain, choiceless nudge.
@export var override_choices: bool = false
@export var choices: Array[DialogueChoice] = []


## True when this variant's condition currently holds. Reads the live Identity state, so it
## reflects everything the player has done up to the moment the line is shown: the running
## counters and the beats already passed.
func is_active() -> bool:
	if require_event != "" and not Identity.has_event(require_event):
		return false
	if forbid_event != "" and Identity.has_event(forbid_event):
		return false
	return CounterCompare.evaluate(Identity.get_value(axis), comparator, threshold)
