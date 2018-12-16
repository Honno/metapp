extends Node2D

onready var VBox = $VBoxContainer
onready var LabelContainer = $VBoxContainer/Bubble/MarginContainer
onready var Label = $VBoxContainer/Bubble/MarginContainer/Label

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
	_debug()

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
		
		_stretch_x(VBox, LabelContainer.get_combined_minimum_size()[0])
		
		_decide_time()
	
	else:
		hide()
		_reset()
		remove_child(timer)
		is_running = false

func _start_timer(wait_time):
	timer.set_wait_time(wait_time)
	timer.start()

func _stretch_x(node, amount):
	node.set_size(Vector2(amount, node.get_size()[1]))
	
func _debug():
	print('>>>')
	print(Label.get_text())
	_print_nodes(self)
	print('<<<')

func _print_nodes(node):
	for child in node.get_children():
		var line = _pretty_size(child)
		if child.get_child_count() > 0:
			print("[%s]" % line)
			_print_nodes(child)
		else:
			print("-%s" % line)

func _pretty_size(node):
	var name = node.get_name()
	if node is Control:
		return "%s : %s" % [node.get_name(), node.get_size()]
	else:
		return name