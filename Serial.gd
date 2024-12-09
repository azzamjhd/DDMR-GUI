extends MarginContainer
@export var max_line = 300

@onready var content = $TextEdit

func _process(delta):
	if content.get_line_count() > max_line:
		var lines = content.text.split("\n")
		lines = lines.slice(1, lines.size())
		content.text = "\n".join(lines)
	content.set_caret_line(content.get_line_count())
