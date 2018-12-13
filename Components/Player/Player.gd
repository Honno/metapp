extends KinematicBody2D

const RUN_FORCE = 512
const MIN_SPEED = 192
const MAX_SPEED = 256
const STOP_FORCE = 2048

const MAX_JUMP_HEIGHT = 80 # in pixels
const JUMP_SPEED = 256
const GRAVITY_PRE = int()
const GRAVITY_POST = int()
const PHI = ( 1 + sqrt(5) ) / 2
var pre_ascent = true

var velocity = Vector2()
var jump_pressed = false
var jumping = false

var current_animation = 'Idle'
onready var sprite = $AnimatedSprite
const ANIM_RUN_SPEED = 16 # Speed at which run animation plays

func _ready():
	GRAVITY_PRE = ( pow(JUMP_SPEED, 2) ) / ( 2 * MAX_JUMP_HEIGHT )
	GRAVITY_POST = GRAVITY_PRE * PHI

func _physics_process(delta):
	### Storing useful information
	var on_floor = is_colliding()
	
	### Input handling
	var left = Input.is_action_pressed('move_left')
	var right = Input.is_action_pressed('move_right')
	var jump_pressed = Input.is_action_just_pressed('jump')
	var jump_released = Input.is_action_just_released('jump')
	
	### Movement logic
	var gravity = GRAVITY_PRE if pre_ascent else GRAVITY_POST
	var force = Vector2(0, gravity)
	
	var stop_x = true

	if left:
		if velocity.x > MIN_SPEED:
			velocity.x = 0
		
		if velocity.x <= MIN_SPEED and velocity.x > -MAX_SPEED:
			force.x -= RUN_FORCE
			stop_x = false
	elif right:
		if velocity.x < -MIN_SPEED:
			velocity.x = 0
		
		if velocity.x >= -MIN_SPEED and velocity.x < MAX_SPEED:
			force.x += RUN_FORCE
			stop_x = false
	
	if stop_x:
		var velocity_length = abs(velocity.x)
		var velocity_sign = sign(velocity.x)
		
		velocity_length -= STOP_FORCE * delta
		if velocity_length < 0:
			velocity_length = 0
		
		velocity.x = velocity_length * velocity_sign
	
	## Jump handling
	if on_floor:
		if jumping:
			jumping = false
			pre_ascent = true
		
		if jump_pressed:
			velocity.y -= JUMP_SPEED
			jumping = true
	
	if jumping:
		if jump_released and velocity.y < 0:
			velocity.y = 0
		
		if pre_ascent and velocity.y >= 0:
			pre_ascent = false
	
	## Apply movement
	velocity += force * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	### Animation handling
	## Assume default animation
	var new_animation = 'Idle'
	
	if on_floor:
		if velocity.x < -ANIM_RUN_SPEED:
			sprite.scale.x = -1
			new_animation = 'Run'
		elif velocity.x > ANIM_RUN_SPEED:
			sprite.scale.x = 1
			new_animation = 'Run'
	elif jumping:
		new_animation = 'Jump'
		if left and not right:
			sprite.scale.x = -1
		if right and not left:
			sprite.scale.x = 1
	
	## Play out new animations
	if new_animation != current_animation:
		current_animation = new_animation
		sprite.play(current_animation)

onready var left = $RayCastLeft
onready var center = $RayCastCenter
onready var right = $RayCastRight

func is_colliding():
	return left.is_colliding() or center.is_colliding() or right.is_colliding()