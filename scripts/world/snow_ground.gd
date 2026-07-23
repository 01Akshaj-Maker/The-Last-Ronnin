extends Node2D

## Snow-pass floor painter (ForgottenMemories tileset recoloured to winter). Same true-autotiling
## approach as the village/grove: a snow field with a trodden trail up to the pass, using the
## pack's real transition tiles (now snow<->packed-path) chosen per-neighbour so the trail melts
## into the snow with frosted edges — no hard squares.
##
## Tiles are 32px local; the node is scaled x2 in the scene (one cell = 64 world px).

@onready var _g: TileMapLayer = $GroundTiles

const SRC := 0
const SNOW := [Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 3), Vector2i(1, 2), Vector2i(3, 2)]
const PATH := [Vector2i(12, 2), Vector2i(13, 2), Vector2i(13, 1)]
const E_N := Vector2i(2, 0)
const E_S := Vector2i(2, 4)
const E_W := Vector2i(0, 2)
const E_E := Vector2i(4, 2)
const O_NW := Vector2i(1, 1)
const O_NE := Vector2i(3, 1)
const O_SW := Vector2i(1, 3)
const O_SE := Vector2i(3, 3)
const I_SE := Vector2i(6, 1)
const I_SW := Vector2i(8, 1)
const I_NE := Vector2i(6, 3)
const I_NW := Vector2i(8, 3)

const CX0 := -23
const CX1 := 24
const CY0 := -18
const CY1 := 17
const WORLD_PER_CELL := 64.0

var _n1 := FastNoiseLite.new()
var _n2 := FastNoiseLite.new()
var _path := {}


func _ready() -> void:
	_n1.noise_type = FastNoiseLite.TYPE_PERLIN
	_n1.seed = 313
	_n1.frequency = 0.05
	_n2.noise_type = FastNoiseLite.TYPE_VALUE
	_n2.seed = 88
	_n2.frequency = 0.7
	_build_path()
	_paint()
	var cam := get_node_or_null("../Actors/Player/Camera2D") as Camera2D
	if cam:
		cam.zoom = Vector2(0.9, 0.9)
		cam.limit_left = -840
		cam.limit_right = 840
		cam.limit_top = -1000
		cam.limit_bottom = 700


func _build_path() -> void:
	# A winding pass trail spawn -> the gate, with two short spurs toward the warden and the rival
	# so the snow reads as a trodden road up the mountain rather than an untouched field.
	var routes := [
		[[Vector2(0, 600), Vector2(-30, 430), Vector2(40, 230), Vector2(-40, 40),
			Vector2(30, -150), Vector2(-20, -340), Vector2(0, -500), Vector2(0, -620)], 1.2],
		[[Vector2(10, -120), Vector2(140, -160), Vector2(210, -185)], 0.9],   # east to the warden
		[[Vector2(-20, -230), Vector2(-120, -330), Vector2(-190, -385)], 0.9],  # up to the rival
	]
	for route in routes:
		var wp: Array = route[0]
		var hw: float = route[1]
		for i in range(wp.size() - 1):
			var a: Vector2 = wp[i]
			var b: Vector2 = wp[i + 1]
			for s in range(30):
				var p: Vector2 = a.lerp(b, float(s) / 30.0)
				_stamp(p, hw + 0.35 * _n2.get_noise_2d(p.x * 0.03, p.y * 0.03))


func _stamp(world_p: Vector2, r: float) -> void:
	var cf := Vector2(world_p.x / WORLD_PER_CELL, world_p.y / WORLD_PER_CELL)
	var ci := int(floor(cf.x))
	var cj := int(floor(cf.y))
	for dy in range(-4, 5):
		for dx in range(-4, 5):
			var cc := Vector2i(ci + dx, cj + dy)
			if Vector2(cc.x + 0.5, cc.y + 0.5).distance_to(cf) <= r + 0.2:
				_path[cc] = true


func _paint() -> void:
	_g.clear()
	for cy in range(CY0, CY1):
		for cx in range(CX0, CX1):
			var c := Vector2i(cx, cy)
			_g.set_cell(c, SRC, _tile_for(c))


func _p(cx: int, cy: int) -> bool:
	return _path.has(Vector2i(cx, cy))


func _tile_for(c: Vector2i) -> Vector2i:
	if _path.has(c):
		return PATH[abs(c.x * 7 + c.y * 13) % PATH.size()]
	var n := _p(c.x, c.y - 1)
	var e := _p(c.x + 1, c.y)
	var s := _p(c.x, c.y + 1)
	var w := _p(c.x - 1, c.y)
	if n and w:
		return O_NW
	if n and e:
		return O_NE
	if s and w:
		return O_SW
	if s and e:
		return O_SE
	if n:
		return E_N
	if s:
		return E_S
	if w:
		return E_W
	if e:
		return E_E
	if _p(c.x + 1, c.y + 1):
		return I_SE
	if _p(c.x - 1, c.y + 1):
		return I_SW
	if _p(c.x + 1, c.y - 1):
		return I_NE
	if _p(c.x - 1, c.y - 1):
		return I_NW
	var v := (_n1.get_noise_2d(c.x, c.y) + 1.0) * 0.5
	if v < 0.12:
		return SNOW[1]
	elif v < 0.2:
		return SNOW[2]
	elif v < 0.26:
		return SNOW[3]
	elif v < 0.3:
		return SNOW[4]
	return SNOW[0]
