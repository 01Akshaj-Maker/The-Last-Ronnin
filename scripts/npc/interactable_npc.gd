extends StaticBody2D

## A placeholder NPC the player can walk up to and talk to (Bible §5.1).
##
## Carries its conversation as data: point `dialogue` at a DialogueData .tres. When the
## player is in range and presses "interact", it emits `interacted` and lets Main decide
## what happens (§9, loose coupling). Add a new talking NPC by instancing this scene, giving
## it a dialogue resource, and putting it in the "npc" group — no code changes.

signal interacted(dialogue: DialogueData)

@export var dialogue: DialogueData

var _player_in_range: bool = false
var _enabled: bool = true

@onready var _prompt: CanvasItem = $Prompt
@onready var _zone: Area2D = $InteractZone


func _ready() -> void:
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
