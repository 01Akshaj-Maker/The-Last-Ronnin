@tool
class_name MoodSet
extends Resource

## The ordered set of grave moods (Bible §3/§6). The ending picks the first mood whose warmth
## range contains the player's warmth, so the mood list is the whole "swap the mood" table in
## one editable data file. Add or retune a mood here — pure data, no code (§9).

@export var moods: Array[MoodData] = []


## First mood whose range contains `warmth`, or null if none match.
func pick(warmth: int) -> MoodData:
	for mood in moods:
		if mood != null and mood.matches(warmth):
			return mood
	return null
