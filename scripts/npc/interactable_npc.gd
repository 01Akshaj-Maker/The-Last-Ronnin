extends StaticBody2D

## A placeholder NPC the player can walk up to and talk to (Bible §5.1).
##
## Carries its conversation as data (`dialogue`) AND its look as data: `npc_animation` picks
## which idle from the shared NPC SpriteFrames to play, with per-instance scale/offset/facing.
## So a new talking NPC is instance + pick an animation + point at a dialogue resource — no
## code (§9). When the player is in range and presses "interact", it emits `interacted` and
## lets Main decide what happens.

signal interacted(dialogue: DialogueData)

@export var dialogue: DialogueData

@export_group("Appearance")
## Animation name in the Sprite's SpriteFrames (e.g. "widow", "ronin", "villager_young").
@export var npc_animation: StringName = &"villager_young"
@export var sprite_scale: Vector2 = Vector2(3.4, 3.4)
@export var sprite_offset: Vector2 = Vector2(0, -10)
## Face left instead of the sheet's default (right).
@export var sprite_flip_h: bool = false

var _player_in_range: bool = false
var _enabled: bool = true

@onready var _prompt: CanvasItem = $Prompt
@onready var _zone: Area2D = $InteractZone
@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_apply_appearance()
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	_refresh_prompt()


func _apply_appearance() -> void:
	_sprite.scale = sprite_scale
	_sprite.offset = sprite_offset
	_sprite.flip_h = sprite_flip_h
	if _sprite.sprite_frames != null and _sprite.sprite_frames.has_animation(npc_animation):
		_sprite.play(npc_animation)
	else:
		push_warning("NPC '%s': animation '%s' not in SpriteFrames" % [name, npc_animation])


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
