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

@onready var _speaker_label: Label = $Root/Box/VBox/Speaker
@onready var _body_label: Label = $Root/Box/VBox/Body
@onready var _choice_rows: Array[Control] = [
	$Root/Box/VBox/Choices/Choice0,
	$Root/Box/VBox/Choices/Choice1,
]
@onready var _choice_labels: Array[Label] = [
	$Root/Box/VBox/Choices/Choice0/Label,
	$Root/Box/VBox/Choices/Choice1/Label,
]
@onready var _hint_label: Label = $Root/Box/VBox/Hint

const _COLOR_SELECTED: Color = Color(1, 1, 1, 1)
const _COLOR_DIMMED: Color = Color(0.58, 0.58, 0.63, 1)

var _data: DialogueData
var _selected: int = 0
var _is_open: bool = false
# The raw choice text, so the selection marker can be re-prefixed without doubling up.
var _choice_texts: Array[String] = ["", ""]
# True while showing a picked choice's follow-up reply (a closing, player-paced beat).
var _awaiting_reply: bool = false
# Ignore the interact key until it is released once, so the same press that opens the box
# cannot immediately confirm a choice.
var _armed: bool = false
var _sb_selected: StyleBoxFlat
var _sb_idle: StyleBoxFlat


func _ready() -> void:
	_build_choice_styles()
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
			_choice_texts[i] = data.choices[i].text
	_hint_label.text = "Enter to continue" if data.choices.is_empty() else "Up / Down to choose      Enter to confirm"
	_is_open = true
	_awaiting_reply = false
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
	if _awaiting_reply:
		# The speaker's reaction to the picked choice: dismiss it to end the conversation.
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
			_close_immediately()
			closed.emit()
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


func _build_choice_styles() -> void:
	_sb_selected = StyleBoxFlat.new()
	_sb_selected.bg_color = Color(0.86, 0.73, 0.48, 0.18)
	_sb_selected.border_width_left = 3
	_sb_selected.border_color = Color(0.9, 0.78, 0.52, 0.95)
	_sb_selected.set_corner_radius_all(6)
	_sb_selected.content_margin_left = 6.0
	_sb_idle = StyleBoxFlat.new()
	_sb_idle.bg_color = Color(1, 1, 1, 0.04)
	_sb_idle.set_corner_radius_all(6)


func _update_highlight() -> void:
	for i in _choice_rows.size():
		var selected: bool = i == _selected
		_choice_rows[i].add_theme_stylebox_override("panel", _sb_selected if selected else _sb_idle)
		_choice_labels[i].modulate = _COLOR_SELECTED if selected else _COLOR_DIMMED
		_choice_labels[i].text = ("▸   " + _choice_texts[i]) if selected else ("     " + _choice_texts[i])


func _confirm() -> void:
	var choice: DialogueChoice = _data.choices[_selected]
	var index: int = _selected
	# Apply the choice's recorded effects now (Main listens); the conversation may go on.
	choice_selected.emit(index, choice)
	if choice.reply != "":
		# Let the speaker react before closing — one player-paced line, no new choices.
		_awaiting_reply = true
		_armed = false
		_body_label.text = choice.reply
		for row in _choice_rows:
			row.visible = false
		_hint_label.text = "Enter to continue"
	else:
		_close_immediately()
		closed.emit()
