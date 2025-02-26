extends CharacterBody2D


const SPEED = 150
const JUMP_VELOCITY = -250
const DOUBLE_JUMP_VELOCITY = -200
const PUSHBACK = 300

var double_jump = true
var coin = 0
var lives = 3
@onready var global = get_node("/root/Global")
@onready var coyotetimer = $CoyoteTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	
	# Add the gravity.
	if is_on_wall_only() and velocity.y > 0:
		velocity.y += (gravity * delta) * 0.005
	elif not is_on_floor():
		velocity.y += gravity * delta * 0.75
	var direction = Input.get_axis("ui_left", "ui_right")

	# Handle jump.
	if Input.is_action_just_pressed("ui_select"):
		if is_on_floor() || !coyotetimer.is_stopped():
			velocity.y = JUMP_VELOCITY
		if is_on_wall_only() and Input.is_action_pressed("ui_right"):
			velocity.y = DOUBLE_JUMP_VELOCITY
			velocity.x = -PUSHBACK 
			double_jump = false
		if is_on_wall_only() and Input.is_action_pressed("ui_left"):
			velocity.y = DOUBLE_JUMP_VELOCITY
			velocity.x = PUSHBACK 
			double_jump = false
	if is_on_wall_only() and not double_jump:
		double_jump = true
	
	if is_on_floor and direction:
		velocity.x = lerp(velocity.x, direction * SPEED, 0.1)
		if is_on_floor():
			$AnimatedSprite2D.play("walk_cycle")
		elif is_on_wall_only() and velocity.y > 0:
			$AnimatedSprite2D.play("wallhang")
		elif not (is_on_wall() and is_on_floor()):
			$AnimatedSprite2D.play("jump")

		if Input.is_action_pressed("ui_left"):
			$AnimatedSprite2D.flip_h = true
		elif Input.is_action_pressed("ui_right"):
			$AnimatedSprite2D.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
		elif not is_on_floor():
			$AnimatedSprite2D.play("jump")
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# Code for coyote timer
	
	if was_on_floor && !is_on_floor():
		coyotetimer.start()
		if Input.is_action_just_pressed("ui_select") and  !is_on_floor():
			coyotetimer.stop()


func _death(area):
	if area.has_meta('spike'):
		if global.lives > 0:
			global.lives -= 1
			position = Vector2(314,604)
		if global.lives < 1:
			global.coin = 0
			global.lives = 3
			get_tree().reload_current_scene()


func _coin(area):
	if area.has_meta("coin"):
		global.coin += 1
		print(global.coin)




# Changes to the win screen
func _on_area_2d_area_entered(area):
	get_tree().change_scene_to_file("res://win.tscn")
