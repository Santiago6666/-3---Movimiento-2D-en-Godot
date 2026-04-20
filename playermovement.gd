extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_running = false
var last_tap_time = 0.0
var double_tap_time = 0.3
var d_jump = false

@onready var animation=$AnimationPlayer
@onready var sprite2d=$Sprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			d_jump = true
		elif d_jump:
			velocity.y = JUMP_VELOCITY * 0.8 
			d_jump = false
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	animations(direction)
	
	move_and_slide()
	
	if direction ==1:
		sprite2d.flip_h =false
	elif direction ==-1:
		sprite2d.flip_h =true
func animations(direction):
	if is_on_floor():
		if direction==0:
			animation.play("idle")
		else:
			animation.play("run")
	else:
		if velocity.y<0:
			animation.play("jump")
		elif velocity.y>0:
			animation.play("fall")
func double_jump(d_jump):
	if is_on_floor():
		d_jump=false
	else:
		d_jump=true
