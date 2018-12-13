extends PopupDialog

onready var Label = $Bubble/Label

const PUNCTUATION = ['.', '!', '?']
const x = 1.00 # Rate of text display
const CHAR_PRINT_TIME = 0.075 * x
const PUNC_PRINT_TIME = CHAR_PRINT_TIME * 3 # Punctuation
const END_LAG_TIME = CHAR_PRINT_TIME * 10

var timer
var is_running
var text
var next_char
var timer_finished
var end

func _reset():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect('timeout', self, '_on_timer_timeout')
	add_child(timer)
	
	is_running = false
	text = String()
	next_char = String()
	timer_finished = false
	end = false

func _ready():
	_reset()

func _process(delta):
	var text_len = text.length()
	
	if is_running:
		if timer_finished:
			if not end:
				Label.	set_text(Label.get_text() + next_char)
				timer_finished = false
				
			else:
				hide()
				_reset()
				is_running = false
			
		elif timer.is_stopped():
			if text_len != 0:
				next_char = text.substr(0, 1)
				text = text.substr(1, text_len)
				
				if not next_char in PUNCTUATION:
					_start_timer(CHAR_PRINT_TIME)
				else:
					_start_timer(PUNC_PRINT_TIME)
				
			else:
				_start_timer(END_LAG_TIME)
				end = true
			
func say(text):
	is_running = true
	self.text = text
	popup()
	
func _start_timer(wait_time):
	timer.set_wait_time(wait_time)
	timer.start()

func _on_timer_timeout():
	timer_finished = true
	