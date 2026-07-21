@tool
class_name RecognitionLine
extends Resource

## One voice in the grave-side recognition (Bible §4 twist, §6 mood). `monk` true = the guide's
## calm, steady words; false = the samurai's own confused, breaking thoughts. Pure data — the
## ending draws each voice in its own way (see ending.gd), never in the ordinary dialogue box.

@export var monk: bool = false
@export_multiline var text: String = ""
