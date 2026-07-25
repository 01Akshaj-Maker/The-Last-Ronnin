extends Node2D

## The final approach (Bible §1 destination, §4 twist, §6 mood) — the quiet bridge between the
## last chapter and the grave. A short, silent walk into thinning fog: no NPCs, no objective,
## only the samurai's sparse thoughts (data, via ChapterGuide onboarding, drifting as he walks).
## The world does NOT close on its own: he walks up to the grave and stands there as long as he
## likes. Only when the player chooses to kneel and read the stone (interact) does the dark draw
## in and the reveal begin — flowing straight into the grave scene on its own pacing from there.
## Wired in as an ordinary (last) chapter, so the director needs no special case; the snow
## chapter's travel card is left blank so nothing interrupts the walk.

## The near-black the grave reveal opens on — we fade to exactly this so the scene swap is
## invisible (dark into dark).
const REVEAL_DARK: Color = Color(0.05, 0.05, 0.06, 1)
## The slowest, most silent moment in the game: the world going out as he kneels to read.
const CLOSE_TIME: float = 4.0

@onready var _player: CharacterBody2D = $Actors/Player
@onready var _grave_zone: Area2D = $GraveZone
@onready var _overlay: ColorRect = $FadeLayer/Overlay
@onready var _prompt: Label = $PromptLayer/GravePrompt
@onready var _sign: StaticBody2D = $Actors/Signpost
@onready var _dialogue_box: CanvasLayer = $DialogueUI

var _at_grave: bool = false
var _ending: bool = false


func _ready() -> void:
	_overlay.color = Color(REVEAL_DARK.r, REVEAL_DARK.g, REVEAL_DARK.b, 0.0)
	_prompt.visible = false
	_grave_zone.body_entered.connect(_on_body_entered)
	_grave_zone.body_exited.connect(_on_body_exited)
	# The wayside sign reads exactly like the village's — an examinable that opens the ordinary
	# dialogue box with the message he leaves behind. Muted while the box is up so the same press
	# that dismisses the message cannot immediately re-open it.
	_sign.interacted.connect(_on_sign_read)
	_dialogue_box.closed.connect(_on_sign_closed)


## The prompt to read the stone appears only once he has reached the grave — until then there is
## nothing to press, just the walk.
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_at_grave = true
		if not _ending:
			_prompt.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_at_grave = false
		_prompt.visible = false


func _on_sign_read(dialogue: DialogueData) -> void:
	_sign.set_enabled(false)
	_dialogue_box.open(dialogue)


func _on_sign_closed() -> void:
	if not _ending:
		_sign.set_enabled(true)


## He reads the grave when the player chooses to — a deliberate press, not a trip-wire — and only
## that begins the end. Reading the sign, by contrast, just opens the message and closes again.
func _process(_delta: float) -> void:
	if _ending or _dialogue_box.visible:
		return
	if _at_grave and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept")):
		_close()


func _close() -> void:
	if _ending:
		return
	_ending = true
	set_process(false)
	_prompt.visible = false
	if _player.has_method("set_movement_enabled"):
		_player.set_movement_enabled(false)
	# The ambient bed fades out with the light as he kneels — the grave is meant to land in silence.
	Music.fade_out()
	# He kneels to read the stone; the world goes slowly, silently dark — to the exact near-black
	# the reveal opens on. The four-second fade IS the moment at the grave.
	var tween: Tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, CLOSE_TIME)
	await tween.finished
	# Straight into the grave reveal, which flows on its own from here. The snow card is blank and
	# this chapter's card is blank, so nothing interrupts — the dark simply carries over.
	GameFlow.advance_chapter()
