extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_running = false
var last_tap_time = 0.0
var double_tap_time = 0.3
var d_jump = false
var is_sliding = false
var slide_friction = 600
var was_on_floor = false
var can_bounce = false
var jump_count = 0
var max_jumps = 2
var is_flying = false
var float_gravity = 100

@onready var animation=$AnimationPlayer
@onready var sprite2d=$Sprite2D

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		if is_flying:
			velocity.y += float_gravity * delta
			
		else:
			velocity += get_gravity() * delta
	if is_flying:
		velocity.y = min(velocity.y, 80)
	if is_flying and not Input.is_action_pressed("ui_accept"):
		is_flying = false
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count = 1
	
		elif jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY * 0.8
			jump_count += 1
	
		else:
			is_flying = true
	var direction := Input.get_axis("ui_left", "ui_right")

	if is_on_floor() and Input.is_action_pressed("ui_down") and direction != 0 and not is_sliding:
		is_sliding = true
		velocity.x = direction * RUN_SPEED 

	if is_sliding:
		velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
		if abs(velocity.x) < 10:
			velocity.x = 0
			is_sliding = false
	elif direction != 0:
		velocity.x = direction * (RUN_SPEED if is_running else SPEED)
	else:
		velocity.x = 0
		is_running = false
	animations(direction)
	
	move_and_slide()
	var just_landed = not was_on_floor and is_on_floor()
	if just_landed and can_bounce:
		velocity.y = -120
		can_bounce = false
		was_on_floor = is_on_floor()
	if is_on_floor():
		jump_count = 0
		is_flying = false
	if direction ==1:
		sprite2d.flip_h =false
	elif direction ==-1:
		sprite2d.flip_h =true
	was_on_floor = is_on_floor()
func _input(event):
	if event.is_action_pressed("ui_right"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_tap_time < double_tap_time:
			is_running = true
		last_tap_time = current_time
	if event.is_action_pressed("ui_left"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_tap_time < double_tap_time:
			is_running = true
		last_tap_time = current_time
func animations(direction):
	if is_sliding:
		animation.play("slide")
	elif is_on_floor():
		if direction == 0:
			animation.play("idle")
		else:
			animation.play("run")
	else:
		if velocity.y < 0:
			animation.play("jump")
		elif velocity.y > 0:
			animation.play("fall")
