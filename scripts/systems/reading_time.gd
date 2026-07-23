class_name ReadingTime
extends RefCounted

## Shared auto-display duration for narration text that advances on its own — the grave reveal
## lines, the travel cards, the opening thoughts (Bible §6 pacing). Longer passages linger
## proportionally longer so they can actually be read; short lines hold at a comfortable floor.
##
## This changes ONLY how long a passage stays up. The text still auto-advances — nothing here
## adds manual advancing. Each caller passes its own existing hold as `minimum`, so short lines
## feel exactly as they did before and only longer ones gain time.

## Extra seconds of reading time per character of text.
const PER_CHARACTER: float = 0.034
## Ceiling, so an unusually long passage lingers well without dragging forever.
const MAXIMUM: float = 9.0


## How long to hold `text` on screen, never shorter than `minimum`.
static func hold_for(text: String, minimum: float) -> float:
	return clampf(minimum + text.length() * PER_CHARACTER, minimum, MAXIMUM)
