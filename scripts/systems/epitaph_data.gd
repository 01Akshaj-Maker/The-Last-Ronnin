@tool
class_name EpitaphData
extends Resource

## The grave epitaph, assembled from counter-gated fragments (Bible §3, "ending state").
##
## `opening` and `closing` always frame the text; every `lines` fragment whose condition holds
## is included in order; `fallback` covers a life that triggered nothing. A merciful life and a
## vengeful one therefore carve clearly different epitaphs. Editable entirely as data (§9) —
## tune fragments and thresholds in the .tres without touching code.

@export_multiline var opening: String = ""
@export var lines: Array[EpitaphLine] = []
@export_multiline var fallback: String = ""
@export_multiline var closing: String = ""


## Build the epitaph for the current Identity state.
func assemble() -> String:
	var parts: PackedStringArray = PackedStringArray()
	if opening != "":
		parts.append(opening)

	# One composed line, not a virtue-list: the single sharpest thing the counters have to say —
	# the active fragment on the axis the player pushed hardest (§3, §6 "felt, not stated").
	var middle: String = _dominant_line()
	if middle == "" and fallback != "":
		middle = fallback
	if middle != "":
		parts.append(middle)

	if closing != "":
		parts.append(closing)
	return "\n".join(parts)


## Among the fragments whose condition holds, the one on the strongest-pushed axis (greatest
## counter magnitude). Ties resolve to the earliest in `lines`, so authoring order is the
## tiebreak. Returns "" when nothing is active, so the caller can fall back.
func _dominant_line() -> String:
	var best_text: String = ""
	var best_magnitude: int = -1
	for line in lines:
		if line == null or not line.is_active():
			continue
		var magnitude: int = abs(Identity.get_value(line.axis))
		if magnitude > best_magnitude:
			best_magnitude = magnitude
			best_text = line.text
	return best_text
