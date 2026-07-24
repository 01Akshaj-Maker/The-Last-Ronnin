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

@export_group("Pointer")
## Float a small bobbing marker over this prop so the player can spot it (Bible §4 clarity). On
## by default for every readable/examinable object. It shows from a distance, ducks out of the
## way once the player is close enough for the "E — <verb>" prompt to appear (so the two never
## overlap), comes back if they wander off without reading it, and retires for good once read.
@export var show_pointer: bool = true
## Height of the marker above the prop's base, in world px (more negative = higher). Leave at 0
## to auto-size it from the collision box; set a value to place it exactly (tall art whose base
## collision is small — a grave, a signpost — needs a larger negative value than auto gives).
@export var pointer_height: float = 0.0

const _BOB_AMPLITUDE: float = 5.0
const _BOB_SPEED: float = 3.2
const _POINTER_FADE: float = 0.25

var _player_in_range: bool = false
var _enabled: bool = true
var _examined: bool = false
var _bob_time: float = 0.0
var _pointer_tween: Tween

@onready var _prompt: Label = $Prompt
@onready var _zone: Area2D = $InteractZone
@onready var _collision: CollisionShape2D = $Collision
@onready var _zone_shape: CollisionShape2D = $InteractZone/ZoneShape
@onready var _pointer: Node2D = get_node_or_null("Pointer")


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
	if _pointer != null:
		_pointer.position.y = _pointer_y()
		_update_pointer(true)
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	_refresh_prompt()


## Resting height of the marker: an explicit `pointer_height`, or auto-derived from the body so
## it clears the prop without per-prop tuning.
func _pointer_y() -> float:
	return pointer_height if pointer_height != 0.0 else -(body_size.y + 30.0)


## Called by Main to mute interaction while a dialogue is already open.
func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	_refresh_prompt()


func _process(delta: float) -> void:
	_bob_pointer(delta)
	if not (_enabled and _player_in_range) or dialogue == null:
		return
	if Input.is_action_just_pressed("interact"):
		_examined = true
		_update_pointer(false)
		interacted.emit(dialogue)


## Gently bob the marker up and down while it is showing.
func _bob_pointer(delta: float) -> void:
	if _pointer == null or not _pointer.visible:
		return
	_bob_time += delta
	_pointer.position.y = _pointer_y() - absf(sin(_bob_time * _BOB_SPEED)) * _BOB_AMPLITUDE


## Bring the marker to its correct state: shown only when the player is NOT in reading range and
## the object has NOT been read yet — so it steps aside for the prompt, returns if the player
## leaves without reading, and stays gone once read. `instant` skips the fade (used on spawn).
func _update_pointer(instant: bool) -> void:
	if _pointer == null:
		return
	var should_show: bool = show_pointer and not _examined and not _player_in_range
	if _pointer_tween != null and _pointer_tween.is_valid():
		_pointer_tween.kill()
	if should_show:
		_pointer.visible = true
		if instant:
			_pointer.modulate.a = 1.0
		else:
			_pointer_tween = create_tween()
			_pointer_tween.tween_property(_pointer, "modulate:a", 1.0, _POINTER_FADE)
	elif instant:
		_pointer.modulate.a = 0.0
		_pointer.visible = false
	else:
		_pointer_tween = create_tween()
		_pointer_tween.tween_property(_pointer, "modulate:a", 0.0, _POINTER_FADE)
		_pointer_tween.tween_callback(func() -> void: _pointer.visible = false)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_refresh_prompt()
		_update_pointer(false)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_refresh_prompt()
		_update_pointer(false)


func _refresh_prompt() -> void:
	if _prompt:
		_prompt.visible = _player_in_range and _enabled
