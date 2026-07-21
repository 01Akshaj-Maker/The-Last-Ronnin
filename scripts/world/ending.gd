extends Control

## The grave — arrival reveal (Bible §1 pitch, §4 twist) wrapped around the counter-driven
## ending (§3, §6). Two things are unchanged and still purely data-driven:
##   1. an EPITAPH assembled from conditional fragments (EpitaphData), and
##   2. a visual MOOD (palette + placeholder particles), chosen by "warmth" (MoodSet).
##
## What is new is only the TIMING and staging around them. The scene opens dark and quiet and
## holds both back while a slow, restrained reveal plays (GraveReveal, all in data): the walk
## up to the grave, the moment he reads his own name, and the seeded hints clicking into place.
## Then the mood blooms and the epitaph assembles. The selection logic below is untouched.

## The grave is meant to land before anything invites the player to move on, so the
## "begin again" prompt stays hidden and inert for this long after the reveal, then fades in.
const REPLAY_DELAY: float = 3.5
## Seconds for the mood + epitaph to fade up once the reveal has finished.
const BLOOM_TIME: float = 2.4
## The quiet near-dark the scene opens on, before the mood blooms in.
const APPROACH_COLOR: Color = Color(0.05, 0.05, 0.06, 1)

@export var epitaph: EpitaphData
@export var mood_set: MoodSet
@export var reveal: GraveReveal

@onready var _background: ColorRect = $Background
@onready var _tint: ColorRect = $Tint
@onready var _particles: CPUParticles2D = $Particles
@onready var _title_label: Label = $Center/VBox/Title
@onready var _epitaph_label: Label = $Center/VBox/Epitaph
@onready var _stats_title_label: Label = $Center/VBox/StatsTitle
@onready var _stats_label: Label = $Center/VBox/Stats
@onready var _hint_label: Label = $Center/VBox/Hint
@onready var _reveal_label: Label = $Reveal

var _can_replay: bool = false


func _ready() -> void:
	# Open on a quiet dark and hold the mood + epitaph back for the reveal.
	_background.color = APPROACH_COLOR
	_tint.color = Color(1, 1, 1, 0)
	_particles.emitting = false
	_title_label.modulate.a = 0.0
	_epitaph_label.modulate.a = 0.0
	_stats_title_label.modulate.a = 0.0
	_stats_label.modulate.a = 0.0
	_hint_label.modulate.a = 0.0
	_reveal_label.modulate.a = 0.0
	# Assemble the epitaph now (from the counters), but keep it hidden until the reveal ends.
	if epitaph != null:
		_epitaph_label.text = epitaph.assemble()
	_stats_label.text = _stats_summary()
	_play_reveal()


## The slow, quiet reveal — one restrained line at a time over the dark approach (§4, §6). Pure
## presentation: it shows GraveReveal.lines and never touches the counters.
func _play_reveal() -> void:
	if reveal != null:
		for line in reveal.lines:
			if not is_inside_tree():
				return
			_reveal_label.text = line
			var t_in: Tween = create_tween()
			t_in.tween_property(_reveal_label, "modulate:a", 0.92, reveal.line_fade)
			await t_in.finished
			await get_tree().create_timer(ReadingTime.hold_for(line, reveal.line_hold)).timeout
			if not is_inside_tree():
				return
			var t_out: Tween = create_tween()
			t_out.tween_property(_reveal_label, "modulate:a", 0.0, reveal.line_fade)
			await t_out.finished
		await get_tree().create_timer(reveal.settle).timeout
	if not is_inside_tree():
		return
	_bloom()


## After the reveal, the counter-driven payoff fades up: the mood (warm/cold) and the epitaph.
## The selection (warmth -> mood, epitaph.assemble) already happened; here we only reveal it.
func _bloom() -> void:
	_apply_mood(mood_set.pick(_warmth()) if mood_set != null else null)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_title_label, "modulate:a", 1.0, BLOOM_TIME)
	tween.tween_property(_epitaph_label, "modulate:a", 1.0, BLOOM_TIME)
	await tween.finished
	# The final tally of who he became fades in after the epitaph has settled (§3 counters,
	# now shown as a closing measure of the road).
	var ledger: Tween = create_tween()
	ledger.set_parallel(true)
	ledger.tween_property(_stats_title_label, "modulate:a", 1.0, 1.1)
	ledger.tween_property(_stats_label, "modulate:a", 1.0, 1.1)
	await ledger.finished
	_arm_replay()


## The four identity counters (Bible §3), shown at the very end as a plain tally of the life
## just lived. Presentation only — the values were accumulated by the choices along the road.
func _stats_summary() -> String:
	return "Honor  %d        Mercy  %d        Attachment  %d        Selflessness  %d" % [
		Identity.get_value("Honor"),
		Identity.get_value("Mercy"),
		Identity.get_value("Attachment"),
		Identity.get_value("Selflessness"),
	]


## Warmth of the life just lived. Mercy and selflessness read warm; attachment (clinging,
## vengeance) reads cold; Honor is deliberately neutral to the mood. One line to retune the
## whole warm/cold axis (§3).
func _warmth() -> int:
	return Identity.get_value("Mercy") + Identity.get_value("Selflessness") - Identity.get_value("Attachment")


func _apply_mood(mood: MoodData) -> void:
	if mood == null:
		return
	# The mood's own caption text is intentionally not shown — the warm/cold light and the
	# drifting blossoms/snow carry it, and the final tally speaks plainly instead.
	_configure_particles(mood)
	# Bloom the light in rather than snapping it on — the mood arriving with the epitaph.
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_background, "color", mood.background_color, BLOOM_TIME)
	tween.tween_property(_tint, "color", mood.tint_color, BLOOM_TIME)


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
