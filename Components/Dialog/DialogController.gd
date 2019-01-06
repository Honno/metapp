extends Node

signal end

export(String, DIR) var translations_path = "res://Levels/Test/Translations"
onready var Player = $"../../Player"
export(Array, NodePath) var characters = [Player]

var YAML = preload("res://bin/gdyaml.gdns").new()
var bubble = preload("res://Components/Dialog/DialogBubble.tscn").instance()

var dialog_script

var dialog_queue = Array()
var current_dialog = null

func _ready():
	## Loading up the script
	var lang = 'en-GB'
	
	var file = File.new()
	var file_path = translations_path + '/' + lang + '.yml'
	file.open(file_path, File.READ)
	var file_text = file.get_as_text()
	
	dialog_script = YAML.parse(file_text)
	
	## Add dialog bubble to the scene
	add_child(bubble)
	bubble.connect('end', self, '_on_bubble_end')
	bubble.translate(Vector2(200, 400))

func _process(delta):
	bubble.set_global_position(Vector2(200, 200))

func play_sequence(id):
	var sequence = dialog_script[id]
	
	for sub_sequence in sequence:
		# First item is presumed the only one we want
		var character = sub_sequence.keys()[0]
		var dialog = sub_sequence.values()[0]
		
		# Handle the translation format which allows for stating multiple lines
		# said by character sequentially in a YAML array
		match typeof(dialog):
			TYPE_STRING:
				_enqueue_dialog(character, dialog)
			TYPE_ARRAY:
				for line in dialog:
					_enqueue_dialog(character, line)

	if current_dialog == null:
		_play_next_dialog()

func _enqueue_dialog(character, text):
	var dialog_entry = {
		'character': character,
		'text': text
	}
	
	dialog_queue.push_back(dialog_entry)
	
func _on_bubble_end():
	if dialog_queue.size() != 0:
		_play_next_dialog()
		
func _play_next_dialog():
	current_dialog = dialog_queue.pop_front()
	bubble.say(current_dialog['text'])
	
func _position_bubble():
	pass