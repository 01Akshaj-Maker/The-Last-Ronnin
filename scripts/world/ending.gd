extends Control

## PLACEHOLDER ending (Bible §5.4 builds the real one). Reads the accumulated Identity
## counters and prints them, plus a one-line "who you became" summary derived from the
## dominant axis. Grey-box, text only — no epitaph assembly or visual mood yet; that is
## Step 4, where this same counter read-out becomes the swapped-mood grave scene (§3).
##
## The raw numbers are shown here only because this is a development read-out. The real
## ending never exposes them.

## Dominant-axis → summary line. A placeholder stand-in for the real epitaph assembly; kept
## as an editable table so tuning the wording is a data-shaped edit.
const DESCRIPTORS: Dictionary = {
	"Honor": "You are remembered as one who held to honor above all else.",
	"Mercy": "You are remembered for the mercy you showed when you needn't have.",
	"Attachment": "You are remembered as one who could never quite let go.",
	"Selflessness": "You are remembered for giving yourself away to others.",
}
const DESCRIPTOR_NEUTRAL: String = "You are remembered only dimly — a shape that passed through."

@onready var _counters_label: Label = $Center/VBox/Counters
@onready var _summary_label: Label = $Center/VBox/Summary


func _ready() -> void:
	var lines: PackedStringArray = PackedStringArray()
	for axis in Identity.AXES:
		lines.append("%s   %d" % [axis, Identity.get_value(axis)])
	_counters_label.text = "\n".join(lines)

	var dominant: String = Identity.dominant_axis()
	_summary_label.text = DESCRIPTORS.get(dominant, DESCRIPTOR_NEUTRAL)


func _process(_delta: float) -> void:
	# TEMP (Step 2): replay from the top to try other choices. Remove with the debug harness.
	if Input.is_action_just_pressed("debug_restart"):
		Identity.reset()
		get_tree().change_scene_to_file("res://scenes/world/Main.tscn")
