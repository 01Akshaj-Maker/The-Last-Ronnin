@tool
class_name GraveRecognition
extends Resource

## The recognition at the grave (Bible §4 twist, §6): the samurai's confusion at reading his own
## name, and the monk — returned from the village as a guide of the dead — gently telling him
## what has happened. Shown NOT in the dialogue box but as bare voices drifting over the dark, so
## it reads as difference, confusion, and death rather than another ordinary conversation. Data
## only: an ordered list of voiced lines and the pacing shared with the rest of the reveal.

@export var lines: Array[RecognitionLine] = []
@export var line_fade: float = 1.2
@export var line_hold: float = 2.2
@export var settle: float = 1.6
