@tool
extends Node2D

## Reusable environment prop. Draws one sprite anchored at its BASE (bottom-centre) so it
## Y-sorts against the player, with an OPTIONAL solid collision box at its base.
##
## `solid` turns on a StaticBody2D barrier. Size it explicitly with `col_size` (in the texture's
## own pixels, before this node's scale), or leave it zero to auto-size a generous box from the
## texture (wide enough that the player stops before visually overlapping the trunk/rock). The
## box scales with the node, so a bigger tree gets a bigger barrier automatically.

@export var texture: Texture2D:
	set(value):
		texture = value
		_apply()
@export var flip_h: bool = false:
	set(value):
		flip_h = value
		_apply()
@export var tint: Color = Color(1, 1, 1, 1):
	set(value):
		tint = value
		_apply()
@export var base_nudge: float = 0.0:
	set(value):
		base_nudge = value
		_apply()
@export var solid: bool = false:
	set(value):
		solid = value
		_apply()
## Collision box in texture-local pixels (scales with the node). Zero = auto from the texture.
@export var col_size: Vector2 = Vector2.ZERO:
	set(value):
		col_size = value
		_apply()
## Shift the box up/down from the base (negative y = up).
@export var col_offset: Vector2 = Vector2.ZERO:
	set(value):
		col_offset = value
		_apply()

@onready var _spr: Sprite2D = $Sprite
@onready var _body: StaticBody2D = $Body
@onready var _shape: CollisionShape2D = $Body/Shape


func _ready() -> void:
	_apply()


func _apply() -> void:
	if _spr == null or _body == null or _shape == null:
		return
	_spr.texture = texture
	_spr.flip_h = flip_h
	_spr.modulate = tint
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_spr.centered = false
	if texture != null:
		var s: Vector2 = texture.get_size()
		_spr.offset = Vector2(-s.x * 0.5, -s.y + base_nudge)
	# Collision.
	if solid and texture != null and _shape.shape is RectangleShape2D:
		var s2: Vector2 = texture.get_size()
		var cw: float = col_size.x if col_size.x > 0.0 else s2.x * 0.5
		var ch: float = col_size.y if col_size.y > 0.0 else s2.y * 0.15 + 10.0
		_shape.shape.size = Vector2(cw, ch)
		# Box bottom rests on the base line; nudged up a hair so feet meet the trunk foot.
		_shape.position = Vector2(0.0, -ch * 0.5 - 4.0) + col_offset
		_shape.disabled = false
		_body.collision_layer = 1
		_body.collision_mask = 0
	else:
		_shape.disabled = true
		_body.collision_layer = 0
		_body.collision_mask = 0
