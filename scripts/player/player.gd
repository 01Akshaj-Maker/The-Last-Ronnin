extends CharacterBody2D

## The ronin. Top-down, 8-directional walk on arrow keys / WASD (Bible §5.1), now with the
## real samurai sprite: an AnimatedSprite2D driven by movement state — idle when still, run
## when moving, flipped to face left/right. Movement is switched off while dialogue is open.
##
## The pack has no walk sheet, so movement uses the "run" animation. attack/hurt exist in the
## SpriteFrames for the later combat step; play_attack()/play_hurt() are ready hooks.

@export var speed: float = 180.0

var _can_move: bool = true

@onready var _sprite: AnimatedSprite2D = $Sprite


func set_movement_enabled(enabled: bool) -> void:
	_can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO
		move_and_slide()


func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if _can_move:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	_update_animation(direction)


## Choose idle vs. run from movement, and face the last horizontal direction. Purely vertical
## movement keeps the current facing.
func _update_animation(direction: Vector2) -> void:
	if direction.length() > 0.01:
		if _sprite.animation != &"run":
			_sprite.play(&"run")
		if direction.x < 0.0:
			_sprite.flip_h = true
		elif direction.x > 0.0:
			_sprite.flip_h = false
	elif _sprite.animation != &"idle":
		_sprite.play(&"idle")


## One-shot hooks for the future combat step; return to idle when the clip finishes.
func play_attack() -> void:
	_play_once(&"attack")


func play_hurt() -> void:
	_play_once(&"hurt")


func _play_once(anim: StringName) -> void:
	_sprite.play(anim)
	await _sprite.animation_finished
	_sprite.play(&"idle")
