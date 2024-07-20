extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var ROLL_VELOCITY = 400

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var attack_area = $"Attack Area"

var is_attacking = false
var attack_phase = 0  # 0: No attack, 1: attack_1, 2: attack_2
var is_rolling = false
var is_hit = false

var death = false

var health: float = 100:
	set(value):
		health = value
		%Health_Bar.value = health
		if health <= 0:
			death = true

func _physics_process(delta):
	if health <= 0:
		if death:
			animation_player.play("death")
			death = false
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("attack") and not is_rolling:
		if not is_attacking:
			attack_phase = 1
			animation_player.play("attack_1")
			is_attacking = true
			velocity.x = 0
		elif attack_phase == 1 and animation_player.is_playing():
			attack_phase = 2
			animation_player.play("attack_2")
			velocity.x = 0

	if is_on_floor() and not is_attacking and not is_rolling:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_just_pressed("roll_left") and not is_attacking:
			start_roll(-1)
		elif Input.is_action_just_pressed("roll_right") and not is_attacking:
			start_roll(1)

	if is_rolling or is_attacking:
		move_and_slide()
	else:
		handle_movement()
		move_and_slide()

func handle_movement():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		switch_direction(1 if direction > 0 else -1)
	if direction:
		velocity.x = (1 if direction > 0 else -1) * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation(direction)

func start_roll(direction):
	velocity.x = direction * ROLL_VELOCITY
	animation_player.speed_scale = ROLL_VELOCITY / 200
	animation_player.play("roll")
	is_rolling = true
	switch_direction(direction)

func roll_anim_end():
	is_rolling = false
	var boss = BossManager.get_boss_by_name("FireKnight")
	if boss != null:
		var direction = (boss.position - global_position)
		switch_direction(1 if direction.x > 0 else -1)
	
func update_animation(direction):
	if is_hit:
		return
	if is_on_floor():
		if direction == 0:
			animation_player.play("idle")
		else:
			animation_player.play("run")
	else:
		if velocity.y < 0:
			animation_player.play("jump")
		elif velocity.y > 0:
			animation_player.play("fall")
		else:
			animation_player.play("jump_fall_in_between")

func switch_direction(direction):
	sprite_2d.flip_h = direction == -1
	sprite_2d.position.x = direction * 4
	attack_area.position.x = direction * 15

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack_1":
		is_attacking = false
		attack_phase = 0
	if anim_name == "attack_2":
		is_attacking = false
		attack_phase = 0
	if anim_name == "roll":
		is_rolling = false
		animation_player.speed_scale = 1
	if anim_name == "hit":
		is_hit = false

func take_damage():
	if not is_hit:
		if is_rolling:
			is_rolling = false
		if is_attacking:
			is_attacking = false
		is_hit = true
		health -= 50
		animation_player.play("hit")
		velocity = Vector2.ZERO
		await get_tree().create_timer(1).timeout
		is_hit = false
		
