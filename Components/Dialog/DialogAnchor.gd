extends Position2D

signal flipped

var flip_h = false
var absolute_x = abs(position.x)

func flip(flip_h):
	self.flip_h = flip_h
	
	position.x = (-1 if flip_h else 1) * absolute_x
	
	emit_signal('flipped', flip_h)

func is_flipped():
	return flip_h