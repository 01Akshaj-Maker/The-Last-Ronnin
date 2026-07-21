extends Node2D

## The final approach (Bible §1 destination, §4 twist, §6 mood) — the quiet bridge between the
## last chapter and the grave. A short, silent walk into thinning fog: no NPCs, no objective,
## only the samurai's sparse thoughts (data, via ChapterGuide onboarding) and the slow dark
## closing in. It is NOT a separate ending — it flows straight into the grave reveal with no
## travel card and no visible cut: the world simply darkens to the reveal's own near-black and
## the reveal begins on it. Wired in as an ordinary (last) chapter, so the director needs no
## special case; the snow chapter's travel card is left blank so nothing interrupts the walk.

## The near-black the grave reveal opens on — we fade to exactly this so the scene swap is
## invisible (dark into dark).
const REVEAL_DARK: Color = Color(0.05, 0.05, 0.06, 1)
## The slowest, most silent moment in the game: the world going out as he arrives.
const CLOSE_TIME: float = 4.0
## Backstop, in case the player never walks to the end — begin the close regardless.
const FALLBACK_DELAY: float = 44.0

@onready var _player: CharacterBody2D = $Actors/Player
@onready var _trigger: Area2D = $EndTrigger
@onready var _overlay: ColorRect = $FadeLayer/Overlay
@onready var _guide: Node = get_node_or_null("ChapterGuide")

var _reached: bool = false
var _narration_done: bool = false
var _ending: bool = false


func _ready() -> void:
	_overlay.color = Color(REVEAL_DARK.r, REVEAL_DARK.g, REVEAL_DARK.b, 0.0)
	_trigger.body_entered.connect(_on_trigger)
	# Only start the close once the last thought has been heard — unless there is no guide.
	if _guide != null and _guide.has_signal("onboarding_finished"):
		_guide.onboarding_finished.connect(_on_narration_done)
	else:
		_narration_done = true
	_fallback()


func _on_trigger(body: Node) -> void:
	if body.is_in_group("player"):
		_reached = true
		_maybe_close()


func _on_narration_done() -> void:
	_narration_done = true
	_maybe_close()


## Close only once he has both arrived at the grave AND finished his last thought — so he stands
## a moment at the stone before the dark takes it.
func _maybe_close() -> void:
	if _reached and _narration_done:
		_close()


func _fallback() -> void:
	await get_tree().create_timer(FALLBACK_DELAY).timeout
	if is_inside_tree():
		_close()


func _close() -> void:
	if _ending:
		return
	_ending = true
	if _player.has_method("set_movement_enabled"):
		_player.set_movement_enabled(false)
	# The world goes slowly, silently dark — to the exact near-black the reveal opens on.
	var tween: Tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, CLOSE_TIME)
	await tween.finished
	# Straight into the grave reveal. The snow card is blank and this chapter's card is blank,
	# so nothing interrupts — the dark simply carries over and the reveal begins on it.
	GameFlow.advance_chapter()
