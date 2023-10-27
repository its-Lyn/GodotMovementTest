extends CharacterBody2D

const SPEED := 250.0
const FRICTION := 75.0
const FALL_MULTIPLIER := 2

const EARTH_GRAVITY := 9.807
const JUMP_MULTIPLIER := 10
const JUMP_FORCE := -500.0
const JUMP_ACC := 40.0
const MIN_JUMP := -150
var jumping := false

@onready var dash_timer := $DashTimer
@onready var dash_cooldown := $FloorDashCooldownTimer
const DASH_TIME := 0.15
const DASH_COOLDOWN_TIME := 0.15
const DASH_MULTIPLIER := 2.2
var dashing := false
var can_dash := true
var dashed_on_floor := false
var dash_dir := 0

@onready var coyote_timer := $CoyoteTimer
const COYOTE_TIME := 0.1
var coyote := false
var last_frame_floor: bool

const GRAVITY := 980
var gravity_disabled := false


func do_dash(direction: int):
	dashing = true
	can_dash = false
	gravity_disabled = true
	dash_dir = direction

	dash_timer.start()


func cancel_dash():
	dashing = false
	gravity_disabled = false


func reset_dash_timer():
	dash_timer.stop()
	dash_timer.wait_time = DASH_TIME


func _ready():
	coyote_timer.wait_time = COYOTE_TIME
	dash_timer.wait_time = DASH_TIME
	dash_cooldown.wait_time = DASH_COOLDOWN_TIME


func _physics_process(delta):
	if is_on_floor() and jumping:
		jumping = false

		if not dashed_on_floor:
			can_dash = true

	if not is_on_floor() and not gravity_disabled:
		velocity.y += GRAVITY * FALL_MULTIPLIER * delta

		if last_frame_floor and !jumping:
			coyote = true
			$CoyoteTimer.start()

	if velocity.y < 0 and Input.is_action_just_released("ui_accept"):
		velocity = Vector2.UP * -EARTH_GRAVITY * JUMP_MULTIPLIER * delta

		if velocity.y > MIN_JUMP:
			velocity.y = MIN_JUMP

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)

	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or coyote):
		if dashing:
			cancel_dash()
			reset_dash_timer()
		
		velocity.x = direction * (SPEED + JUMP_ACC)
		velocity.y = JUMP_FORCE
		
		jumping = true
		
		if coyote:
			coyote = false

	if Input.is_action_just_pressed("Dash") and can_dash:
		if is_on_floor():
			dashed_on_floor = true
			dash_cooldown.start()

		do_dash(direction)
	
	if dashing:
		if dash_dir == 0:
			dash_dir = 1

		var vel = dash_dir * (SPEED * DASH_MULTIPLIER)
		velocity.y = 0
		velocity.x = vel

	last_frame_floor = is_on_floor()
	move_and_slide()


func _on_coyote_timer_timeout():
	coyote = false


func _on_dash_timer_timeout():
	cancel_dash()


func _on_floor_dash_cooldown_timer_timeout():
	if is_on_floor():
		can_dash = true
