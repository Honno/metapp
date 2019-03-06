extends Node

signal bubble_end
signal dialog_end

export(String, DIR) var translations_path
export(Array, NodePath) var characters

var YAML = preload("res://bin/gdyaml.gdns").new()
var BubbleScene = preload("res://Components/Dialog/DialogBubble.tscn")
var bubble

var dialog_script

var dialog_queue = Array()
var current_dialog = null
var current_character

var Anchor
var initial_anchor_x

func _ready():
	## Loading up the script
	var lang = 'en-GB'
	
	var file = File.new()
	var file_path = translations_path + '/' + lang + '.yml'
	file.open(file_path, File.READ)
	var file_text = file.get_as_text()
	
	dialog_script = YAML.parse(file_text)

func _process(delta):
	if current_dialog != null:
		var anchor_pos = Anchor.get_global_position()
		bubble.set_position(anchor_pos)
		bubble.set_player_offset_x(anchor_pos.x - initial_anchor_x)

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

func cut():
	current_dialog = null

func _enqueue_dialog(character, text):
	var dialog_entry = {
		'character': character,
		'text': text
	}
	
	dialog_queue.push_back(dialog_entry)
	
func _on_bubble_end():
	remove_child(bubble)
	Anchor.disconnect('flipped', self, '_on_Anchor_flipped')
	
	emit_signal('bubble_end')
	
	if dialog_queue.size() != 0:
		_play_next_dialog()
	else:
		current_dialog = null
		Anchor = null
		emit_signal('dialog_end')
		
func _play_next_dialog():
	current_dialog = dialog_queue.pop_front()
	
	bubble = BubbleScene.instance()
	bubble.connect('end', self, '_on_bubble_end')
	add_child(bubble)
	
	current_character = _get_character_node(current_dialog['character'])
	
	Anchor = current_character.get_node("./DialogAnchor")
	initial_anchor_x = Anchor.get_global_position().x
	Anchor.connect('flipped', self, '_on_Anchor_flipped')
	
	bubble.flip_tail(Anchor.is_flipped())
	bubble.say(current_dialog.text)
	
func _get_character_node(character):
	for nodepath in characters:
		var node = get_node(nodepath)
		if node.get_name() == character:
			return node
			
func _on_Anchor_flipped(flip_h):
	bubble.flip_tail(flip_h)