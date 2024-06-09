extends CharacterBody2D

# Variables for movement
@export var move_speed = 50
@export var spin_speed = 25
@onready var label = $Label

# Onready variables for animations
@onready var animated_sprite = $AnimatedSprite2D

# State variables
enum State { IDLE, RUNNING, PREP_ATTACK, CHARGE_ATTACK, ATTACK, PREP_SPIN, SPIN, SPIN_END }
var current_state = State.IDLE

# State names for debugging
var state_names = {
	State.IDLE: "Idle",
	State.RUNNING: "Running",
	State.PREP_ATTACK: "Prep Attack",
	State.CHARGE_ATTACK: "Charge Attack",
	State.ATTACK: "Attack",
	State.PREP_SPIN: "Prep Spin",
	State.SPIN: "Spin",
	State.SPIN_END: "Spin End"
}

# Functions
func _ready():
	animated_sprite = $AnimatedSprite2D
	label = $Label

func _physics_process(_delta):
	state_machine()
	move_and_slide()
	handle_animation()

func state_machine():
	match current_state:
		State.IDLE:
			handle_idle()
		State.RUNNING:
			handle_running()
		State.PREP_ATTACK:
			handle_prep_attack()
		State.CHARGE_ATTACK:
			handle_charge_attack()
		State.ATTACK:
			handle_attack()
		State.PREP_SPIN:
			handle_prep_spin()
		State.SPIN:
			handle_spin()
		State.SPIN_END:
			handle_spin_end()

	# Update the label with the current state name
	label.text = "State: " + state_names[current_state]

func handle_idle():
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO:
		current_state = State.RUNNING
	elif Input.is_action_just_pressed("attack"):
		current_state = State.PREP_ATTACK
	elif Input.is_action_just_pressed("spin"):
		current_state = State.PREP_SPIN
	velocity = Vector2.ZERO

func handle_running():
	var input_direction = get_input_direction()
	if input_direction == Vector2.ZERO:
		current_state = State.IDLE
	elif Input.is_action_just_pressed("attack"):
		current_state = State.PREP_ATTACK
	elif Input.is_action_just_pressed("spin"):
		current_state = State.PREP_SPIN
	velocity = input_direction.normalized() * move_speed

func handle_prep_attack():
	velocity = Vector2.ZERO

func handle_charge_attack():
	if Input.is_action_just_released("attack"):
		current_state = State.ATTACK
	velocity = Vector2.ZERO

func handle_attack():
	velocity = Vector2.ZERO

func handle_prep_spin():
	velocity = Vector2.ZERO

func handle_spin():
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * spin_speed
	else:
		velocity = Vector2.ZERO
	if Input.is_action_just_released("spin"):
		current_state = State.SPIN_END

func handle_spin_end():
	current_state = State.IDLE
	velocity = Vector2.ZERO

func get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1

	return direction

func handle_animation():
	# Flip sprite based on direction
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.RUNNING:
			animated_sprite.play("run")
		State.PREP_ATTACK:
			animated_sprite.play("prep_attack")
		State.CHARGE_ATTACK:
			animated_sprite.play("charge_attack")
		State.ATTACK:
			animated_sprite.play("attack")
		State.PREP_SPIN:
			animated_sprite.play("prep_spin")
		State.SPIN:
			animated_sprite.play("spin")
		State.SPIN_END:
			animated_sprite.play("spin_end")

func _on_animated_sprite_2d_animation_finished():
	var current_animation = animated_sprite.animation
	if current_animation == "attack" and current_state == State.ATTACK:
		current_state = State.IDLE
	elif current_animation == "spin_end" and current_state == State.SPIN_END:
		current_state = State.IDLE
	elif current_animation == "prep_attack" and current_state == State.PREP_ATTACK:
		current_state = State.CHARGE_ATTACK
	elif current_animation == "prep_spin" and current_state == State.PREP_SPIN:
		current_state = State.SPIN

