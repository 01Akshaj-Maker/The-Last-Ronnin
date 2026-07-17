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

@export var axis: String = "Honor"
## One of: ">=", "<=", ">", "<", "==", "!="
@export var comparator: String = ">="
@export var threshold: int = 1
@export_multiline var body: String = ""


## True when this variant's condition currently holds. Reads the live Identity counters, so
## it reflects everything the player has done up to the moment the line is shown.
func is_active() -> bool:
	return _compare(Identity.get_value(axis), threshold)


func _compare(value: int, target: int) -> bool:
	match comparator:
		">=": return value >= target
		"<=": return value <= target
		">": return value > target
		"<": return value < target
		"==": return value == target
		"!=": return value != target
		_:
			push_warning("DialogueVariant: unknown comparator '%s' (treated as false)" % comparator)
			return false
