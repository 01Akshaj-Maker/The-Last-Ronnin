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

	var matched: PackedStringArray = PackedStringArray()
	for line in lines:
		if line != null and line.is_active():
			matched.append(line.text)
	if matched.is_empty() and fallback != "":
		matched.append(fallback)
	parts.append_array(matched)

	if closing != "":
		parts.append(closing)
	return "\n".join(parts)
