extends StaticBody2D

## A placeholder NPC the player can walk up to and talk to (Bible §5.1).
##
## Carries its conversation as data (`dialogue`) AND its look as data: `npc_animation` picks
## which idle from the shared NPC SpriteFrames to play, with per-instance scale/offset/facing
## and a per-instance solid `body_size` (kept close to the scaled sprite so the player can't
## walk through it). So a new talking NPC is instance + pick an animation + point at a dialogue
## resource — no code (§9).

signal interacted(dialogue: DialogueData)

@export var dialogue: DialogueData

@export_group("Appearance")
## Animation name in the Sprite's SpriteFrames (e.g. "widow", "ronin", "villager_young").
@export var npc_animation: StringName = &"villager_young"
@export var sprite_scale: Vector2 = Vector2(3.2, 3.2)
@export var sprite_offset: Vector2 = Vector2(0, -7)
## Face left instead of the sheet's default (right).
@export var sprite_flip_h: bool = false
## Solid collision footprint (world px). Sized near the visible body so the player bumps the
## sprite instead of overlapping it.
@export var body_size: Vector2 = Vector2(42, 56)

var _player_in_range: bool = false
var _enabled: bool = true

@onready var _prompt: CanvasItem = $Prompt
@onready var _zone: Area2D = $InteractZone
@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _collision: CollisionShape2D = $Collision


func _ready() -> void:
	_apply_appearance()
	_apply_collision()
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


func _apply_collision() -> void:
	if _collision.shape is RectangleShape2D:
		_collision.shape.size = body_size


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
