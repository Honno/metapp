extends VBoxContainer

onready var Label = $CenterContainer/MarginContainer/Label

const PUNCTUATION = ['.', '!', '?']
const x = 1.00 # Rate of text display
const CHAR_PRINT_TIME = 0.075 * x
const PUNC_PRINT_TIME = CHAR_PRINT_TIME * 3 # Punctuation
const END_LAG_TIME = CHAR_PRINT_TIME * 10

var timer
var is_running
var text
var text_len
var next_char
var timer_finished
var end

func _reset():
	Label.set_text(String())
	
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect('timeout', self, '_on_timer_timeout')
	add_child(timer)
	
	is_running = false
	text = String()
	text_len = int()
	next_char = String()
	end = false

func _ready():
	hide()

func _process(delta):
	print('>>>')
	print($CenterContainer.get_size())
	print($CenterContainer/MarginContainer.get_size())
	print($CenterContainer/MarginContainer/Label.get_size())
	print('<<<')

func say(text):
	_reset()
	is_running = true
	
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
		_reset()
		remove_child(timer)
		is_running = false

func _start_timer(wait_time):
	timer.set_wait_time(wait_time)
	timer.start()