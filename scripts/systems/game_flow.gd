extends Node

## The director (Bible §2, §4). Walks the player through the fixed journey:
## intro -> each chapter in order -> the grave. The chapter order lives in data
## (res://data/flow/game_flow.tres); this script just follows it, so adding a chapter is a
## data edit plus an exit trigger in that chapter — no change here (§9).
##
## Autoload, so it (and the Identity counters) persist across every scene change. It owns a
## top-most CanvasLayer used for the fade-to-black and the interstitial travel card.

const FADE_TIME: float = 0.45
const CARD_FADE: float = 0.6
const CARD_HOLD: float = 1.6

var _data: GameFlowData
var _index: int = -1        # -1 before the first chapter; 0..n-1 while in a chapter
var _busy: bool = false     # guards against double-triggered transitions

var _fade: ColorRect
var _card: Label


func _ready() -> void:
	_data = load("res://data/flow/game_flow.tres")
	_build_overlay()


func get_intro_title() -> String:
	return _data.intro_title


func get_intro_body() -> String:
	return _data.intro_body


## Begin a fresh run: reset the counters and load the first chapter (no travel card).
func start_game() -> void:
	if _busy:
		return
	Identity.reset()
	_index = 0
	await _go(_data.chapters[0].scene_path, "")


## Called by a chapter's exit trigger. Shows the chapter's travel card, then loads the next
## chapter — or, after the last chapter, the grave. Counters carry over (autoload).
func advance_chapter() -> void:
	if _busy or _index < 0 or _index >= _data.chapters.size():
		return
	var card: String = _data.chapters[_index].travel_text
	_index += 1
	if _index < _data.chapters.size():
		await _go(_data.chapters[_index].scene_path, card)
	else:
		await _go(_data.ending_scene, card)


## Back to the intro (used by the grave's replay).
func restart() -> void:
	if _busy:
		return
	Identity.reset()
	_index = -1
	await _go(_data.intro_scene, "")


func _go(scene_path: String, card_text: String) -> void:
	_busy = true
	await _fade_to(1.0)
	if card_text != "":
		await _show_card(card_text)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await _fade_to(0.0)
	_busy = false


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_TIME)
	await tween.finished


func _show_card(text: String) -> void:
	_card.text = text
	var t_in: Tween = create_tween()
	t_in.tween_property(_card, "modulate:a", 1.0, CARD_FADE)
	await t_in.finished
	await get_tree().create_timer(ReadingTime.hold_for(text, CARD_HOLD)).timeout
	var t_out: Tween = create_tween()
	t_out.tween_property(_card, "modulate:a", 0.0, CARD_FADE)
	await t_out.finished


func _build_overlay() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 128  # above all game UI
	add_child(layer)

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.anchor_right = 1.0
	_fade.anchor_bottom = 1.0
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)

	_card = Label.new()
	_card.anchor_right = 1.0
	_card.anchor_bottom = 1.0
	_card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card.modulate = Color(1, 1, 1, 0)
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_card)
