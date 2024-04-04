extends CharacterBody2D


const SPEED: float = 75.0 # walking speed
const MAX_RUN: float = 135.0 # running speed not the max fully yet
const MAX_SPRINT: float = 180.0 # the highest speed 

const ACCEL: float = 337.5# how fast it goes from 0 to 135
const DECEL: float = 225 # how fast it goes back to 0 velocity

const P_METER_START = 131.25 # from this number on it starts the p_meter aka the actual running so it hit the max cap
const MAX_P_METER = 1.867 # this is the maximum the p meter can hold

var p_meter: float = 0.0 # p meter itself
const JUMP_VELOCITY = -400.0 

var jump_pressed_time = 0.0
const RUN_JUMP_VELOCITY = -450.0
const SPIN_JUMP_VELOCITY = -290
const PMETER_VELOCITY = -490.0
var speedup = false;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation = get_node("AnimatedSprite2D")
var facing_direction = -1


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
	_spin()
	var spinning = _spin()
	_jump_speed(spinning)
	var fly = _handle_jumping()
	_accel_and_decel(direction,max_speed,delta, spinning , fly)
	_p_meteranimations()
	_crouch(delta)
	_facing_direction(direction)
	
	
	
	move_and_slide()
func _handle_jumping():
	var fly = false
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if(abs(velocity.x) == MAX_SPRINT ):
			velocity.y = PMETER_VELOCITY
			animation.play("mini_fly")
			fly = true
		else:
			velocity.y = JUMP_VELOCITY
			speedup = false;
			animation.play("mini_jump") # silly jump
	if(Input.is_action_just_released("jump") && velocity.y < 0):
		velocity.y *= 0.5
	return fly
func _jump_speed(spinning):
	var base_speed = JUMP_VELOCITY
	var speed_incr
	if spinning:
		base_speed = SPIN_JUMP_VELOCITY
		speed_incr = S # finishing check your other chats for the rest of the code remmeber
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
func _accel_and_decel(direction,max_speed,delta, spinning , fly):
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
	print(spinning)
	if(velocity.y > 0 && !spinning && !fly):
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
func _spin():
	var spinning = true;
	if(Input.is_action_pressed("spin") && is_on_floor()):
		animation.play("mini_spin")
		velocity.y = SPIN_JUMP_VELOCITY
		spinning = true;
		
	return spinning
