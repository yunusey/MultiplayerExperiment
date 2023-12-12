extends Node2D

var is_current_textbox: bool = false
var word: String = "something"

var caret_position: int = 0
const FORMAT_STRING: String = """\
[color={typed_color}]{typed_text}[/color]|[color={remaining_color}]{remaining_text}[/color]
"""

func set_textbox(_is_current_textbox: bool, _word: String):
	self.is_current_textbox = _is_current_textbox
	self.word = _word

func _ready():
	self.update_label()

func _process(_delta):
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_BACKSPACE:
			if self.caret_position > 0:
				self.caret_position -= 1
		elif event.pressed and event.keycode == KEY_ENTER:
			self.caret_position = 0
		elif event.pressed and event.keycode == KEY_SPACE:
			self.caret_position += 1

		self.update_label()

func update_label():
	$Label.text = FORMAT_STRING.format({
		"typed_color": "#00ffff" if is_current_textbox else "#ffffff",
		"typed_text": self.word.substr(0, caret_position),
		"remaining_color": "#00ffff" if is_current_textbox else "#ffffff",
		"remaining_text": self.word.substr(caret_position),
	})
