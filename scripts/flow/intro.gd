extends Control

## The opening screen. Shows the title and opening lines (pulled from GameFlow's data, so the
## text stays editable as data), and starts the journey on interact/Enter.

@onready var _title: Label = $Center/VBox/Title
@onready var _body: Label = $Center/VBox/Body


func _ready() -> void:
	_title.text = GameFlow.get_intro_title()
	_body.text = GameFlow.get_intro_body()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
		set_process(false)
		GameFlow.start_game()
