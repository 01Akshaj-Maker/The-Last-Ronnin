extends CanvasLayer

## Grey-box dialogue UI. Shows a speaker, body text, and up to two choices; the player
## moves the selection with up/down (or left/right) and confirms with interact/Enter.
##
## Knows nothing about NPCs or the player — it is opened with a DialogueData and reports
## back which choice was picked, then hides itself (Bible §9). The body it shows is whatever
## the data resolves to now (DialogueData.get_active_body()), which is how reflected-world
## variants (§3) surface here without this UI knowing anything about the counters.

signal choice_selected(index: int, choice: DialogueChoice)
signal closed

@onready var _speaker_label: Label = $Root/Panel/Margin/VBox/Speaker
@onready var _body_label: Label = $Root/Panel/Margin/VBox/Body
@onready var _choice_rows: Array[Control] = [
	$Root/Panel/Margin/VBox/Choices/Choice0,
	$Root/Panel/Margin/VBox/Choices/Choice1,
]
@onready var _choice_labels: Array[Label] = [
	$Root/Panel/Margin/VBox/Choices/Choice0/Label,
	$Root/Panel/Margin/VBox/Choices/Choice1/Label,
]
@onready var _hint_label: Label = $Root/Panel/Margin/VBox/Hint

const _COLOR_SELECTED: Color = Color(1, 1, 1, 1)
const _COLOR_DIMMED: Color = Color(0.55, 0.55, 0.6, 1)

var _data: DialogueData
var _selected: int = 0
var _is_open: bool = false
# Ignore the interact key until it is released once, so the same press that opens the box
# cannot immediately confirm a choice.
var _armed: bool = false


func _ready() -> void:
	_close_immediately()


func open(data: DialogueData) -> void:
	_data = data
	_speaker_label.text = data.speaker
	_body_label.text = data.get_active_body()
	_selected = 0
	for i in _choice_rows.size():
		var has_choice: bool = i < data.choices.size()
		_choice_rows[i].visible = has_choice
		if has_choice:
			_choice_labels[i].text = data.choices[i].text
	_hint_label.text = "Enter to continue" if data.choices.is_empty() else "Up / Down to choose      Enter to confirm"
	_is_open = true
	_armed = false
	visible = true
	_update_highlight()


func _process(_delta: float) -> void:
	if not _is_open:
		return
	if not _armed:
		if not Input.is_action_pressed("interact"):
			_armed = true
		return
	var count: int = _data.choices.size()
	if count == 0:
		# A choiceless line (e.g. an examined object): interact/Enter just dismisses it.
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
			_close_immediately()
			closed.emit()
		return
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_left"):
		_selected = (_selected - 1 + count) % count
		_update_highlight()
	elif Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_right"):
		_selected = (_selected + 1) % count
		_update_highlight()
	elif Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
		_confirm()


func _close_immediately() -> void:
	_is_open = false
	visible = false


func _update_highlight() -> void:
	for i in _choice_rows.size():
		_choice_rows[i].modulate = _COLOR_SELECTED if i == _selected else _COLOR_DIMMED


func _confirm() -> void:
	var choice: DialogueChoice = _data.choices[_selected]
	var index: int = _selected
	_close_immediately()
	choice_selected.emit(index, choice)
	closed.emit()
