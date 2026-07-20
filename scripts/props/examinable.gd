extends StaticBody2D

## A world object the player can examine (Bible §4 interaction clarity). Same contract as an
## NPC — it shows a contextual "E — <verb>" prompt in range and emits `interacted(dialogue)`
## so Main opens the dialogue box with it — but it is a prop, not a character: no choices, just
## a line to read. Put it in the "interactable" group and Main auto-wires it (§9).

signal interacted(dialogue: DialogueData)

@export var dialogue: DialogueData
## Shown in the prompt as "E — <verb>" (e.g. "read", "examine").
@export var prompt_verb: String = "examine"
## Objective beat this reports to the chapter guide when examined (e.g. "found_bell"); empty
## means examining it advances nothing (pure flavor). Matches ObjectiveStep.advance_on (§4).
@export var guide_event: String = ""
## Solid footprint so the player bumps the prop instead of walking through it.
@export var body_size: Vector2 = Vector2(24, 44)
## Optional grey-box tint for a child ColorRect named "Body" (props with a single block look).
@export var body_color: Color = Color(0.32, 0.28, 0.22, 1)
@export var interact_radius: float = 74.0

var _player_in_range: bool = false
var _enabled: bool = true

@onready var _prompt: Label = $Prompt
@onready var _zone: Area2D = $InteractZone
@onready var _collision: CollisionShape2D = $Collision
@onready var _zone_shape: CollisionShape2D = $InteractZone/ZoneShape


func _ready() -> void:
	if _collision.shape is RectangleShape2D:
		_collision.shape.size = body_size
	if _zone_shape.shape is CircleShape2D:
		_zone_shape.shape.radius = interact_radius
	var body: Node = get_node_or_null("Body")
	if body is ColorRect:
		body.color = body_color
		body.size = body_size
		body.position = -body_size / 2.0
	_prompt.text = "E — %s" % prompt_verb
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	_refresh_prompt()


## Called by Main to mute interaction while a dialogue is already open.
func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	_refresh_prompt()


func _process(_delta: float) -> void:
	if not (_enabled and _player_in_range) or dialogue == null:
		return
	if Input.is_action_just_pressed("interact"):
		interacted.emit(dialogue)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_refresh_prompt()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_refresh_prompt()


func _refresh_prompt() -> void:
	if _prompt:
		_prompt.visible = _player_in_range and _enabled
