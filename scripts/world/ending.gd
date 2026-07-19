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

@export var epitaph: EpitaphData
@export var mood_set: MoodSet

@onready var _background: ColorRect = $Background
@onready var _tint: ColorRect = $Tint
@onready var _particles: CPUParticles2D = $Particles
@onready var _epitaph_label: Label = $Center/VBox/Epitaph
@onready var _caption_label: Label = $Center/VBox/Caption


func _ready() -> void:
	_apply_mood(mood_set.pick(_warmth()) if mood_set != null else null)
	if epitaph != null:
		_epitaph_label.text = epitaph.assemble()


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


func _process(_delta: float) -> void:
	# TEMP (debug): replay the whole journey from the intro. Remove with the debug harness.
	if Input.is_action_just_pressed("debug_restart"):
		set_process(false)
		GameFlow.restart()
