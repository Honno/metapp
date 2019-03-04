extends AnimatedSprite

onready var DialogAnchor = $DialogAnchor
var original_anchor_y
var anchor_absolute_x

const period = 4 # in s
const amplitude = 8 # in something
var time_elapsed = 0

func _ready():
	original_anchor_y = DialogAnchor.position.y
	anchor_absolute_x = DialogAnchor.position.x
	
	_flip()

func _process(delta):
	time_elapsed = wrapf(time_elapsed + delta, 0, period)
	offset.y = amplitude * sin((time_elapsed / period) * 2 * PI)
	$DialogAnchor.position.y = original_anchor_y + offset.y

func _flip():
	DialogAnchor.flip(flip_h)