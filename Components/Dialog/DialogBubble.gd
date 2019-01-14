extends Node2D

signal end

export(NodePath) var DialogContainer
export(NodePath) var TextContainer
export(NodePath) var TextLabel

var prev_text_container_width

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
	
	prev_text_container_width = TextContainer.get_size().x
	
	TextLabel.set_text(String())
	
	timer = Timer.new()
	timer.connect('timeout', self, '_on_timer_timeout')
	add_child(timer)
	
	DialogContainer.connect('draw', self, '_on_DialogContainer_draw')

func say(text):
	text_len = text.length()
	self.text = text

	show()
	_decide_time()
	
func set_offset_x(offset):
	player_offset_x = offset

func _decide_time():
	if TextLabel.get_text().length() != text_len:
		next_char = text.substr(0, 1)
		text = text.substr(1, text.length()-1)

		if next_char in PUNCTUATION:
			_start_timer(PUNC_PRINT_TIME)
		else:
			_start_timer(CHAR_PRINT_TIME)

	else:
		_start_timer(END_LAG_TIME)
		end = true

func _start_timer(wait_time):
	timer.set_wait_time(wait_time)
	timer.start()

func _on_timer_timeout():
	if not end:
		TextLabel.set_text(TextLabel.get_text() + next_char)
		
		_decide_time()

	else:
		hide()
		
		emit_signal('end')
		queue_free()

func _on_DialogContainer_draw():
	var text_container_width = TextContainer.get_size().x
	var width_increased_by = text_container_width - prev_text_container_width
	DialogContainer.margin_left -= width_increased_by / 2
	
	prev_text_container_width = text_container_width
