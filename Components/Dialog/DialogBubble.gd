extends Node2D

signal end

export(NodePath) var TextContainerPath
export(NodePath) var TextLabelPath
export(NodePath) var TailTexturePath
export(int) var tail_margin

onready var TextContainer = get_node(TextContainerPath)
onready var TextLabel = get_node(TextLabelPath)
onready var Tail = get_node(TailTexturePath)

var container_width
var container_margin_min
var container_margin_max
var tail_width

var player_offset_x = 0

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
	
	container_width = TextContainer.get_size().x
	tail_width = Tail.get_size().x
	
	_calculate_margin_range()
	
	timer = Timer.new()
	timer.connect('timeout', self, '_on_timer_timeout')
	add_child(timer)
	
	TextContainer.connect('draw', self, '_on_TextContainer_draw')

func say(text):
	text_len = text.length()
	self.text = text

	show()
	_decide_time()
	
func set_player_offset_x(offset):
	var offset_delta = offset - player_offset_x
	player_offset_x = offset
	TextContainer.margin_left = clamp(TextContainer.margin_left - offset_delta, container_margin_min, container_margin_max)

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
		
func _on_TextContainer_draw():
	_calculate_margin_range()

func _calculate_margin_range():
	var container_width_delta = TextContainer.get_size().x - container_width
	container_margin_min = -container_width_delta - tail_margin
	container_margin_max = container_width_delta - tail_margin