extends Node

## Hidden identity counters — the load-bearing system (Bible §3).
##
## Four axes accumulate across the whole game from the choices the player makes. The player
## NEVER sees these numbers; they only feel the consequences (a reflected world now, an
## epitaph and visual mood at the grave later).
##
## Registered as the autoload singleton "Identity" so the counters persist across scene
## changes. Choices carry their effects as DATA (DialogueChoice.effects); apply_effects() is
## the single entry point, so authoring a new choice with new effects never touches code (§9).

## The four dimensions of character. One source of truth — adding/renaming an axis is a
## one-line change here.
const AXES: Array[String] = ["Honor", "Mercy", "Attachment", "Selflessness"]

var _counters: Dictionary = {}
## Named story beats the player has passed (e.g. "talked_thief", "found_bell"). Unlike the
## counters, these are booleans of "has this happened yet" — they let a later conversation frame
## itself by what the player has already done (Bible §3 reflected world, ordering-aware). Set on
## a conversation closing (Main), read by event-conditioned dialogue variants.
var _events: Dictionary = {}


func _ready() -> void:
	reset()


## Return every axis to 0 and forget every beat. Used at game start and by the debug replay.
func reset() -> void:
	_counters.clear()
	for axis in AXES:
		_counters[axis] = 0
	_events.clear()


## Record that a named beat has happened. Empty names are ignored (a beatless interactable).
func mark_event(event: String) -> void:
	if event != "":
		_events[event] = true


## True once the named beat has been recorded this game.
func has_event(event: String) -> bool:
	return _events.has(event)


## Move a single axis by amount (may be negative). Unknown axes are ignored with a warning
## so a typo in data never crashes the game.
func adjust(axis: String, amount: int) -> void:
	if not _counters.has(axis):
		push_warning("Identity.adjust: unknown axis '%s' (ignored)" % axis)
		return
	_counters[axis] += amount


## Apply a whole effects map, e.g. {"Mercy": 2, "Honor": -1}. This is what a picked choice
## feeds in — pure data, no per-choice code.
func apply_effects(effects: Dictionary) -> void:
	for axis in effects:
		adjust(axis, int(effects[axis]))


func get_value(axis: String) -> int:
	return int(_counters.get(axis, 0))


## A copy of all counters {axis: value}. Copy so callers can't mutate state directly.
func get_all() -> Dictionary:
	return _counters.duplicate()


## The single strongest axis. Returns "" when everything is 0 or the top is tied, so callers
## can fall back to a neutral reading rather than arbitrarily picking a winner.
func dominant_axis() -> String:
	var best_axis: String = ""
	var best_value: int = 0
	var tied: bool = false
	for axis in AXES:
		var value: int = _counters[axis]
		if value > best_value:
			best_value = value
			best_axis = axis
			tied = false
		elif value == best_value and value > 0:
			tied = true
	if best_value <= 0 or tied:
		return ""
	return best_axis
