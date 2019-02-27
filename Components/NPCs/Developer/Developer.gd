extends AnimatedSprite

const period = 4 # in s
const amplitude = 0.25 # in something
var time_elapsed = 0

func _process(delta):
	time_elapsed = wrapf(time_elapsed + delta, 0, period)
	var y = amplitude * sin((time_elapsed / period) * 2 * PI)
	move_local_y(y)