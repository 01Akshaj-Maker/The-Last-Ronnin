@tool
class_name GraveReveal
extends Resource

## The arrival-at-the-grave reveal (Bible §1 pitch, §4 twist), authored entirely as data so the
## wording and the pacing can be tuned without code. The `lines` are shown one at a time — slow
## and quiet, over a dark and near-silent approach — BEFORE the counter-driven epitaph: the walk
## up, the realization the grave is his own, and the seeded hints clicking into place in
## hindsight. Only after the reveal does the mood bloom and the epitaph assemble (§3, unchanged).
##
## Keep it restrained: let silence and one short line ("It is your own.") carry the weight, not
## explanation. Timing lives here too, so the beat can breathe or quicken.

## The reveal lines, shown in order.
@export var lines: PackedStringArray = PackedStringArray()
## Seconds to fade each line in, and to fade it out again.
@export var line_fade: float = 1.3
## Seconds to hold each line at full before it fades.
@export var line_hold: float = 2.2
## Extra silence after the final line before the epitaph and mood bloom in.
@export var settle: float = 1.6
