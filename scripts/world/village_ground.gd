extends Node2D

## Village terrain painter (ForgottenMemories pack, v3). One grass field with a winding dirt
## road, using the pack's real grass<->dirt transition tiles selected per-neighbour (true
## autotiling) so the road melts into the grass with tufted edges and rounded corners — no
## hard squares. Grass gets low-frequency variation; the road is a hand-waypointed S-curve.
##
## Tiles are 32px in this node's local space; the node is scaled x2 in the scene (one cell =
## 64 world px). Deterministic; hand-repaintable in the editor.

@onready var _g: TileMapLayer = $GroundTiles

const SRC := 0
# Atlas coords into the FM tileset (col,row).
const GRASS := [Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 3), Vector2i(1, 2), Vector2i(3, 2)]
# Only the plainest interior dirt tiles — the outer ones have baked light blobs that read as odd patches.
const DIRT := [Vector2i(12, 2), Vector2i(13, 2), Vector2i(13, 1)]
# grass cells that border the dirt road: edges, outer (convex) corners, inner (concave) corners.
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

# Blanket well beyond the walls (world ±800 / ±600) so peripheral vision never hits the void.
const CX0 := -22
const CX1 := 23
const CY0 := -18
const CY1 := 19
const WORLD_PER_CELL := 64.0

var _n1 := FastNoiseLite.new()
var _n2 := FastNoiseLite.new()
var _path := {}


func _ready() -> void:
	_n1.noise_type = FastNoiseLite.TYPE_PERLIN
	_n1.seed = 1337
	_n1.frequency = 0.05
	_n2.noise_type = FastNoiseLite.TYPE_VALUE
	_n2.seed = 99
	_n2.frequency = 0.7
	_build_path()
	_paint()
	# Village camera: zoomed in a touch, and limited so it never scrolls past the painted grass
	# into the black void beyond the map.
	var cam := get_node_or_null("../Actors/Player/Camera2D") as Camera2D
	if cam:
		cam.zoom = Vector2(0.85, 0.85)
		cam.limit_left = -1180
		cam.limit_right = 1180
		cam.limit_top = -1000
		cam.limit_bottom = 1000


func _build_path() -> void:
	# A main road (spawn -> north gate) with short spurs branching off to each house-ruin, so
	# the network reads as village streets serving homesteads. [route_points, half_width_cells].
	var routes := [
		[[Vector2(0, 620), Vector2(55, 360), Vector2(-20, 140), Vector2(40, -110),
			Vector2(-10, -310), Vector2(0, -480), Vector2(0, -620)], 1.35],
		[[Vector2(-10, 150), Vector2(180, 145), Vector2(275, 150)], 1.0],   # east to well/centre
		[[Vector2(-15, -150), Vector2(-190, -165), Vector2(-320, -170)], 1.0],  # west to RuinA
		[[Vector2(25, -175), Vector2(220, -185), Vector2(330, -190)], 1.0],  # east to RuinB
		[[Vector2(-10, 175), Vector2(-200, 200), Vector2(-350, 210)], 1.0],  # west to RuinC
		[[Vector2(-10, -400), Vector2(-150, -435), Vector2(-250, -450)], 1.0],  # up to Temple
	]
	for route in routes:
		var wp: Array = route[0]
		var hw: float = route[1]
		for i in range(wp.size() - 1):
			var a: Vector2 = wp[i]
			var b: Vector2 = wp[i + 1]
			for s in range(30):
				var p: Vector2 = a.lerp(b, float(s) / 30.0)
				_stamp(p, hw + 0.4 * _n2.get_noise_2d(p.x * 0.03, p.y * 0.03))
	# A worn village-square clearing where the roads meet.
	_stamp(Vector2(10, 140), 2.4)


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
		return DIRT[abs(c.x * 7 + c.y * 13) % DIRT.size()]
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
	# concave (inner) corners — dirt only on a diagonal
	if _p(c.x + 1, c.y + 1):
		return I_SE
	if _p(c.x - 1, c.y + 1):
		return I_SW
	if _p(c.x + 1, c.y - 1):
		return I_NE
	if _p(c.x - 1, c.y - 1):
		return I_NW
	# plain grass with low-frequency variation
	var v := (_n1.get_noise_2d(c.x, c.y) + 1.0) * 0.5
	if v < 0.12:
		return GRASS[1]
	elif v < 0.2:
		return GRASS[2]
	elif v < 0.26:
		return GRASS[3]
	elif v < 0.3:
		return GRASS[4]
	return GRASS[0]
