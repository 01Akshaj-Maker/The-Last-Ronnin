extends CanvasLayer

## The player-guidance overlay (Bible §4 clarity without breaking §6's mood). Deliberately
## quiet: a readable objective line at the top (the samurai's standing mission), the samurai's
## opening thoughts fading in the lower third, and a controls hint that leaves once the player
## has acted. It knows nothing about NPCs or the world — Main tells it when to advance or
## dismiss (§9). All text is data (`ChapterGuideData`), so a new chapter drops in a ChapterGuide
## with its own resource.
##
## An objective either advances on a single beat (`advance_on`) or gathers several
## (`requires`) — the latter shows a "(2 of 4)" tally so the player can see what is left. While
## a chapter still has a goal to finish, `is_ready_to_leave()` is false, which a chapter exit
## can honour to keep the player from leaving before the place has been heard out.

## Emitted once the opening thoughts have all played out. The final approach waits on this so
## its walk-into-the-dark only begins after the samurai's last thought has been heard.
signal onboarding_finished

@export var data: ChapterGuideData

const OBJECTIVE_ALPHA: float = 0.96
const CONTROLS_ALPHA: float = 0.4
const THOUGHT_ALPHA: float = 0.85
const NOTICE_ALPHA: float = 0.92
const THOUGHT_HOLD: float = 2.6
const NOTICE_HOLD: float = 2.2

@onready var _pill: Control = $ObjectiveCenter/ObjectivePill
@onready var _objective: Label = $ObjectiveCenter/ObjectivePill/ObjectiveText
@onready var _thought: Label = $Thought
@onready var _controls: Label = $Controls
@onready var _notice: Label = $Notice

var _index: int = 0
var _controls_dismissed: bool = false
var _gathered: Dictionary = {}
var _notice_tween: Tween


func _ready() -> void:
	_thought.modulate.a = 0.0
	_notice.modulate.a = 0.0
	if data == null:
		_objective.text = ""
		_pill.modulate.a = 0.0
		_controls.text = ""
		return
	_controls.text = data.controls_hint
	_controls.modulate.a = CONTROLS_ALPHA if data.controls_hint != "" else 0.0
	_apply_objective(false)
	_play_onboarding()


## Report a chapter beat (e.g. "talked_monk"). Completes the current objective if it is the
## awaited single beat, or ticks the gather tally and completes once every required beat is in.
func report_event(event: String) -> void:
	if data == null or _index >= data.objectives.size():
		return
	var step: ObjectiveStep = data.objectives[_index]
	if not step.requires.is_empty():
		if step.requires.has(event) and not _gathered.has(event):
			_gathered[event] = true
			if _count_gathered(step) >= step.requires.size():
				_advance()
			else:
				_pulse_objective()
		return
	if step.advance_on != "" and step.advance_on == event:
		_advance()


## True once the current objective has no goal left to finish (the standing "leave" step, or no
## objectives at all). A gated chapter exit checks this before letting the player move on (§4).
func is_ready_to_leave() -> bool:
	if data == null or _index >= data.objectives.size():
		return true
	var step: ObjectiveStep = data.objectives[_index]
	return step.advance_on == "" and step.requires.is_empty()


## Briefly show a gentle line (e.g. when the player reaches a still-locked exit). Reuses the
## quiet lower-third register; kills any prior notice so they don't stack.
func flash_notice(text: String) -> void:
	_notice.text = text
	if _notice_tween != null and _notice_tween.is_valid():
		_notice_tween.kill()
	_notice_tween = create_tween()
	_notice_tween.tween_property(_notice, "modulate:a", NOTICE_ALPHA, 0.35)
	_notice_tween.tween_interval(ReadingTime.hold_for(text, NOTICE_HOLD))
	_notice_tween.tween_property(_notice, "modulate:a", 0.0, 0.6)


## Fade out the controls hint the first time the player interacts — they've learned it.
func mark_interacted() -> void:
	if _controls_dismissed:
		return
	_controls_dismissed = true
	var tween: Tween = create_tween()
	tween.tween_property(_controls, "modulate:a", 0.0, 0.8)


func _advance() -> void:
	_index += 1
	_gathered.clear()
	_apply_objective(true)


func _count_gathered(step: ObjectiveStep) -> int:
	var n: int = 0
	for beat in step.requires:
		if _gathered.has(beat):
			n += 1
	return n


func _current_text() -> String:
	if _index >= data.objectives.size():
		return ""
	var step: ObjectiveStep = data.objectives[_index]
	var text: String = step.text
	if not step.requires.is_empty():
		text += "      ( %d of %d )" % [_count_gathered(step), step.requires.size()]
	return text


func _apply_objective(fade: bool) -> void:
	var text: String = _current_text()
	var shown: String = ("◇   " + text) if text != "" else ""
	if not fade:
		_objective.text = shown
		_pill.modulate.a = OBJECTIVE_ALPHA if shown != "" else 0.0
		return
	var tween: Tween = create_tween()
	tween.tween_property(_pill, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void: _objective.text = shown)
	tween.tween_property(_pill, "modulate:a", OBJECTIVE_ALPHA if shown != "" else 0.0, 0.55)


## A small brighten-and-settle when a gather tally ticks up, so the player feels it register.
func _pulse_objective() -> void:
	_objective.text = "◇   " + _current_text()
	var tween: Tween = create_tween()
	tween.tween_property(_pill, "modulate:a", 0.55, 0.12)
	tween.tween_property(_pill, "modulate:a", OBJECTIVE_ALPHA, 0.35)


func _play_onboarding() -> void:
	for line in data.onboarding:
		if not is_inside_tree():
			return
		_thought.text = line
		var t_in: Tween = create_tween()
		t_in.tween_property(_thought, "modulate:a", THOUGHT_ALPHA, 0.9)
		await t_in.finished
		await get_tree().create_timer(ReadingTime.hold_for(line, THOUGHT_HOLD)).timeout
		if not is_inside_tree():
			return
		var t_out: Tween = create_tween()
		t_out.tween_property(_thought, "modulate:a", 0.0, 0.9)
		await t_out.finished
	if is_inside_tree():
		onboarding_finished.emit()
