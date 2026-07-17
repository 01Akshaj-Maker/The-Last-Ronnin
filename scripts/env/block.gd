@tool
extends StaticBody2D

## Grey-box solid block — a placeholder wall, building, or prop with collision (Bible §9).
##
## Instance it and set `block_size` and `block_color` per instance; the origin is the block's
## centre. No art: the human team replaces these greys with real sprites / tilesets and
## hand-tunes the layout later (§9 clear ownership). @tool so the box previews live while
## laying out the scene in the editor.

@export var block_size: Vector2 = Vector2(64, 64):
	set(value):
		block_size = value
		_apply()
@export var block_color: Color = Color(0.24, 0.24, 0.28, 1.0):
	set(value):
		block_color = value
		_apply()

@onready var _body: ColorRect = $Body
@onready var _shape: CollisionShape2D = $Collision


func _ready() -> void:
	_apply()


func _apply() -> void:
	# Setters can fire before the child nodes exist (during load); guard until _ready wires them.
	if _body == null or _shape == null:
		return
	_body.size = block_size
	_body.position = -block_size * 0.5
	_body.color = block_color
	if _shape.shape is RectangleShape2D:
		_shape.shape.size = block_size
