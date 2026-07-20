extends Control

## The grave — real ending assembly (Bible §3 "ending state", §6 visual mood).
##
## Reads the accumulated Identity counters and assembles two things:
##   1. an EPITAPH, from data-driven conditional fragments (EpitaphData), and
##   2. a visual MOOD (palette + placeholder particles), chosen by "warmth" (MoodSet).
##
## Both the epitaph fragments and the moods live in data (res://data/ending/), so new content
## is a data edit, never a code edit (§9). The visuals here are deliberate placeholders — a
## tinted ColorRect for light and CPUParticles2D squares for blossoms/snow. Real art/shaders
## can replace them later: the selection logic below reads only from data and never changes.

## The grave is meant to land before anything invites the player to move on, so the
## "begin again" prompt stays hidden and inert for this long, then fades in.
const REPLAY_DELAY: float = 3.5

@export var epitaph: EpitaphData
@export var mood_set: MoodSet

@onready var _background: ColorRect = $Background
@onready var _tint: ColorRect = $Tint
@onready var _particles: CPUParticles2D = $Particles
@onready var _epitaph_label: Label = $Center/VBox/Epitaph
@onready var _caption_label: Label = $Center/VBox/Caption
@onready var _hint_label: Label = $Center/VBox/Hint

var _can_replay: bool = false


func _ready() -> void:
	_apply_mood(mood_set.pick(_warmth()) if mood_set != null else null)
	if epitaph != null:
		_epitaph_label.text = epitaph.assemble()
	_arm_replay()


## Warmth of the life just lived. Mercy and selflessness read warm; attachment (clinging,
## vengeance) reads cold; Honor is deliberately neutral to the mood. One line to retune the
## whole warm/cold axis (§3).
func _warmth() -> int:
	return Identity.get_value("Mercy") + Identity.get_value("Selflessness") - Identity.get_value("Attachment")


func _apply_mood(mood: MoodData) -> void:
	if mood == null:
		return
	_background.color = mood.background_color
	_tint.color = mood.tint_color
	_caption_label.text = mood.caption
	_configure_particles(mood)


func _configure_particles(mood: MoodData) -> void:
	_particles.emitting = mood.particle_enabled
	if not mood.particle_enabled:
		return
	var view: Vector2 = get_viewport_rect().size
	# Emit along the top edge, fall down across the whole screen.
	_particles.position = Vector2(view.x * 0.5, -16.0)
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = Vector2(view.x * 0.5 + 40.0, 6.0)
	_particles.amount = mood.particle_amount
	_particles.color = mood.particle_color
	_particles.gravity = mood.particle_gravity
	_particles.lifetime = 9.0
	_particles.direction = Vector2(0, 1)
	_particles.spread = 12.0
	_particles.initial_velocity_min = 12.0
	_particles.initial_velocity_max = 30.0
	_particles.scale_amount_min = 3.0
	_particles.scale_amount_max = 6.0


## Hold the "begin again" prompt back until the grave has had a moment to land, then fade
## it in and allow the replay. Keeps the ending from feeling like a menu.
func _arm_replay() -> void:
	_hint_label.modulate.a = 0.0
	await get_tree().create_timer(REPLAY_DELAY).timeout
	_can_replay = true
	var tween: Tween = create_tween()
	tween.tween_property(_hint_label, "modulate:a", 1.0, 1.2)


func _process(_delta: float) -> void:
	if _can_replay and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept")):
		set_process(false)
		GameFlow.restart()
