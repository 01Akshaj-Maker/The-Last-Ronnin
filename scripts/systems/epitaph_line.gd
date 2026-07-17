@tool
class_name EpitaphLine
extends Resource

## One conditional fragment of the grave epitaph (Bible §3, "ending state"). It is included in
## the assembled epitaph when its condition holds against the Identity counters — so the
## dominant axes of a life select which lines are carved.
##
## Pure data: author a fragment by adding one to an EpitaphData's `lines` and setting
## axis / comparator / threshold / text. No code (§9). Reads as "<axis> <comparator> <threshold>".

@export_multiline var text: String = ""
@export var axis: String = "Honor"
## One of: ">=", "<=", ">", "<", "==", "!="
@export var comparator: String = ">="
@export var threshold: int = 1


func is_active() -> bool:
	return CounterCompare.evaluate(Identity.get_value(axis), comparator, threshold)
