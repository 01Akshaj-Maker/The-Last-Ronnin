extends CharacterBody2D

## The ronin. Top-down, 8-directional walk on arrow keys / WASD (Bible §5.1).
##
## No art yet — the visual is a grey ColorRect placed in the scene (§9, art is the human
## team's job). Movement is switched off while a dialogue is open; Main owns that wiring so
## the player stays unaware of the dialogue system.

@export var speed: float = 180.0

var _can_move: bool = true


func set_movement_enabled(enabled: bool) -> void:
	_can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO
		move_and_slide()


func _physics_process(_delta: float) -> void:
	if not _can_move:
		return
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
