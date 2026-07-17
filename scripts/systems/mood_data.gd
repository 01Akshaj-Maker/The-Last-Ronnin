@tool
class_name MoodData
extends Resource

## A grave-scene visual mood (Bible §3 "ending state", §6 visual direction), chosen by the
## "warmth" the ending derives from the Identity counters (mercy/letting-go reads warm;
## vengeance/attachment reads cold).
##
## Everything here is placeholder-friendly DATA — palette + particle params — so real art and
## shaders can replace the visuals later without touching the selection logic. Add a new mood
## by adding another MoodData to the MoodSet; no code (§9).

@export var id: String = ""
@export_multiline var caption: String = ""

## This mood applies when warmth is within [min_warmth, max_warmth], inclusive.
@export var min_warmth: int = -999
@export var max_warmth: int = 999

## --- Placeholder visuals (swap for real art later) ---
@export var background_color: Color = Color(0.1, 0.11, 0.13, 1)
## Full-screen overlay standing in for "light" (warm amber vs cold blue). Its alpha matters.
@export var tint_color: Color = Color(1, 1, 1, 0)
@export var particle_enabled: bool = false
@export var particle_color: Color = Color(1, 1, 1, 1)
## Fall direction/speed of the placeholder flakes/petals (snow straight & fast, blossoms drift).
@export var particle_gravity: Vector2 = Vector2(0, 30)
@export var particle_amount: int = 40


func matches(warmth: int) -> bool:
	return warmth >= min_warmth and warmth <= max_warmth
