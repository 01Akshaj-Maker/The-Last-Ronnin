class_name CounterCompare
extends RefCounted

## Shared evaluation of a "<value> <comparator> <target>" integer test, used by everything
## that gates content on the Identity counters — reflected-world dialogue variants (§3) and
## epitaph fragments (§3 ending). Kept in one place so the comparator set stays consistent (§9).


static func evaluate(value: int, comparator: String, target: int) -> bool:
	match comparator:
		">=": return value >= target
		"<=": return value <= target
		">": return value > target
		"<": return value < target
		"==": return value == target
		"!=": return value != target
		_:
			push_warning("CounterCompare: unknown comparator '%s' (treated as false)" % comparator)
			return false
