extends CanvasLayer

## The player-guidance overlay (Bible §4 clarity without breaking §6's mood). Deliberately
## quiet: a faint objective line at the top, the samurai's opening thoughts fading in the
## lower third, and a controls hint that leaves once the player has acted. It knows nothing
## about NPCs or the world — Main tells it when to advance or dismiss (§9). All text is data
## (`ChapterGuideData`), so a new chapter drops in a ChapterGuide with its own resource.

@export var data: ChapterGuideData

const OBJECTIVE_ALPHA: float = 0.62
const CONTROLS_ALPHA: float = 0.4
const THOUGHT_ALPHA: float = 0.85
const THOUGHT_HOLD: float = 2.6

@onready var _objective: Label = $Objective
@onready var _thought: Label = $Thought
@onready var _controls: Label = $Controls

var _index: int = 0
var _controls_dismissed: bool = false


func _ready() -> void:
	_thought.modulate.a = 0.0
	if data == null:
		_objective.text = ""
		_controls.text = ""
		return
	_controls.text = data.controls_hint
	_controls.modulate.a = CONTROLS_ALPHA if data.controls_hint != "" else 0.0
	_apply_objective(false)
	_play_onboarding()


## Report a chapter beat (e.g. "talked"). If it completes the current objective, advance.
func report_event(event: String) -> void:
	if data == null or _index >= data.objectives.size():
		return
	var step: ObjectiveStep = data.objectives[_index]
	if step.advance_on != "" and step.advance_on == event:
		_index += 1
		_apply_objective(true)


## Fade out the controls hint the first time the player interacts — they've learned it.
func mark_interacted() -> void:
	if _controls_dismissed:
		return
	_controls_dismissed = true
	var tween: Tween = create_tween()
	tween.tween_property(_controls, "modulate:a", 0.0, 0.8)


func _apply_objective(fade: bool) -> void:
	var text: String = ""
	if _index < data.objectives.size():
		text = data.objectives[_index].text
	var shown: String = ("◇   " + text) if text != "" else ""
	if not fade:
		_objective.text = shown
		_objective.modulate.a = OBJECTIVE_ALPHA if shown != "" else 0.0
		return
	var tween: Tween = create_tween()
	tween.tween_property(_objective, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void: _objective.text = shown)
	tween.tween_property(_objective, "modulate:a", OBJECTIVE_ALPHA if shown != "" else 0.0, 0.55)


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
