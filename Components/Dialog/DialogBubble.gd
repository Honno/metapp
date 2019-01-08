extends Node2D

signal end

onready var Label = $VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/Label

const PUNCTUATION = ['.', '!', '?']
const x = 1.00 # Rate of text display
const CHAR_PRINT_TIME = 0.075 * x
const PUNC_PRINT_TIME = CHAR_PRINT_TIME * 3 # Punctuation
const END_LAG_TIME = CHAR_PRINT_TIME * 10

var text
var text_len
var next_char
var end
var timer

func _ready():
	hide()
	
	Label.set_text(String())
	
	text = String()
	text_len = int()
	next_char = String()
	end = false
	
	timer = Timer.new()
	timer.connect('timeout', self, '_on_timer_timeout')
	add_child(timer)

func say(text):
	text_len = text.length()
	self.text = text

	show()
	_decide_time()

func _decide_time():
	if Label.get_text().length() != text_len:
		next_char = text.substr(0, 1)
		text = text.substr(1, text.length()-1)

		if next_char in PUNCTUATION:
			_start_timer(PUNC_PRINT_TIME)
		else:
			_start_timer(CHAR_PRINT_TIME)

	else:
		_start_timer(END_LAG_TIME)
		end = true

func _on_timer_timeout():
	if not end:
		Label.set_text(Label.get_text() + next_char)

		_decide_time()

	else:
		hide()
		
		emit_signal('end')
		queue_free()

func _start_timer(wait_time):
	timer.set_wait_time(wait_time)
	timer.start()