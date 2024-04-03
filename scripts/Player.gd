extends CharacterBody2D


const SPEED: float = 135.0 # walking speed
const MAX_RUN: float = 180.0 # running speed not the max fully yet
const MAX_SPRINT: float = 230.0 # the highest speed 

const ACCEL: float = 225.0 # how fast it goes from 0 to 135
const DECEL: float = 500 # how fast it goes back to 0 velocity

const P_METER_START = 178.25 # from this number on it starts the p_meter aka the actual running so it hit the max cap
const MAX_P_METER = 1.867 # this is the maximum the p meter can hold

var p_meter: float = 0.0 # p meter itself
const JUMP_VELOCITY = -400.0 

var jump_pressed_time = 0.0
const RUN_JUMP_VELOCITY = -450.0
const SPIN_JUMP_VELOCITY = -290
var speedup = false;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation = get_node("AnimatedSprite2D")
var facing_direction = -1
var spinning = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	_pmeter_calc(delta)
	_handle_jumping()
	var direction = Input.get_axis("backwards", "forward")
	_speed_calc()
	var result = _speed_calc()
	var max_speed = result[0]
	var jump_velocity = result[1]
	_accel_and_decel(direction,max_speed,delta)
	_p_meteranimations()
	_crouch(delta)
	_facing_direction(direction)
	
	
	
	move_and_slide()
func _handle_jumping():
	if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			speedup = false;
			animation.play("mini_jump") # silly jump
	if(Input.is_action_just_released("jump") && velocity.y < 0):
		velocity.y *= 0.5
func _p_meteranimations():
	if velocity.x:
		if (p_meter == MAX_P_METER && velocity.y == 0): #max of the p_meter and checks wether youre not in the air
			animation.play("mini_run")
		elif (p_meter != MAX_P_METER && velocity.y == 0): #if its not equal rto the max amount and checks wether youre not in the air
			animation.play("mini_walk")
	else:
		if(velocity.y == 0): # when its on the ground the Y axis is 0 so it goes idle
			animation.play("mini_idle")
		
func _speed_calc():
	var max_speed = SPEED
	var jump_velocity = JUMP_VELOCITY
	if Input.is_action_pressed("running"):
		speedup = true;
		jump_velocity = RUN_JUMP_VELOCITY
		if p_meter >= MAX_P_METER:
				max_speed = MAX_SPRINT
		else:
			max_speed = MAX_RUN
	else:
			max_speed = SPEED
			jump_velocity = JUMP_VELOCITY
	return [max_speed, jump_velocity]

func _pmeter_calc(delta):
	if(is_on_floor() && abs(velocity.x) >= P_METER_START && Input.is_action_pressed("running")): # checks wether its on the floor and if the velocity is higher than the starting number, also the input
		p_meter = min(p_meter + 2 * delta, MAX_P_METER) # increase the p_meter double the amount of the amount of time that has gone by a frame and caps it at the max
	else:
		p_meter = max(p_meter - delta , 0) # decreases - 2 and multiplied by the time in each frame has passed, the min cap is 0
	# Handle jump.
func _accel_and_decel(direction,max_speed,delta):
	if direction:
		print(velocity.x)
		if((direction * velocity.x) < 0):
			velocity.x = move_toward(velocity.x, 0, DECEL * 2 * delta)
		else:
			velocity.x = move_toward(velocity.x , direction * max_speed, ACCEL * delta)
		facing_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta) # decelerates the max speed and multiplied with delta
		facing_direction = direction # saves direction
	if(velocity.y > 0):
		animation.play("mini_fall")
	
func _crouch(delta):
	if(Input.is_action_pressed("down") && velocity.y == 0):
		animation.play("mini_crouch")
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
func _facing_direction(direction):
	if(direction* sign(velocity.x) == -1 && velocity.y == 0): # causes the turning animation to happen whent he direction switches to a negative number
		animation.play("mini_turn")
	if(facing_direction == -1):
		animation.flip_h = true
	elif(facing_direction == 1):
		animation.flip_h = false
