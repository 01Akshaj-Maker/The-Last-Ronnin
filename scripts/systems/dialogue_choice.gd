@tool
class_name DialogueChoice
extends Resource

## One selectable option in a dialogue prompt.
##
## For the core-loop skeleton (Bible §5.1) a choice only carries its label. The identity
## system (§3, Step 2) will extend this resource with counter effects — kept separate from
## DialogueData so that stays a localized addition, not a rewrite.

@export_multiline var text: String = ""
