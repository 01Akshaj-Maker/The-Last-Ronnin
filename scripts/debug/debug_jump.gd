extends CanvasLayer

## TEMP (Step 2 test harness): press the "debug_end" action (G) to jump straight to the
## placeholder ending, so the accumulated Identity counters can be inspected mid-play before
## the real chapter flow exists. Delete this node (and scenes/debug/, scripts/debug/) once a
## real chapter reaches the ending. Self-contained so removal is one clean step (§9).

@export_file("*.tscn") var ending_scene_path: String = "res://scenes/ending/Ending.tscn"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_end"):
		get_tree().change_scene_to_file(ending_scene_path)
