@tool
class_name DialogueChoice
extends Resource

## One selectable option in a dialogue prompt.
##
## `text` is the label. `effects` is the choice's impact on the hidden identity counters
## (Bible §3), authored purely as data: a map of {axis_name: delta}, e.g.
## {"Mercy": 2, "Honor": -1}. When the choice is picked, Main feeds `effects` straight into
## Identity.apply_effects() — so adding a new weighted choice is a data edit, never a code
## change (§9). Leave `effects` empty for a choice that changes nothing mechanically.
##
## `reply` is the speaker's reaction to this choice: one closing line shown (player-paced, like
## an examined prop) after the choice is picked, before the box closes — so a conversation can
## breathe into a real exchange without changing the flow or the recorded values (§9). Leave it
## empty to close immediately as before.

@export_multiline var text: String = ""
@export var effects: Dictionary = {}
@export_multiline var reply: String = ""
