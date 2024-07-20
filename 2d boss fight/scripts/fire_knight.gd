extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]

@export var target: CharacterBody2D
@export var SPEED: int = 100

@onready var sprite_2d = $Sprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var special_attack_active = false
var running = false
var attacking = false
var taking_damage = false

const melee_attacks = ["attack_1", "attack_2", "attack_3"]

var death = false

var health: float = 100:
	set(value):
		health = value
		%Health_Bar.value = health
		if health <= 0:
			death = true
func _ready():
	BossManager.add_boss(self)
	
func _exit_tree():
	BossManager.remove_boss(self)

func _physics_process(delta):
	if health <= 0:
		if death:
			state_machine.travel("death")
			death = false
		return
	#print(attacking, running, taking_damage)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if not attacking and not taking_damage:
		if target:
			handle_movement(target)
		else:
			running = false
			idle()

	move_and_slide()

func handle_movement(target):
	var target_dif = target.position - global_position
	if abs(target_dif.x) < 100:
		melee_attack()
		return

	change_facing_direction()

	var direction = -1 if sprite_2d.flip_h else 1
	velocity.x = direction * SPEED
	running = true
	state_machine.travel("run")

func melee_attack():
	if not attacking:
		attacking = true
		velocity.x = 0  # Durdur
		state_machine.travel(melee_attacks[randi() % melee_attacks.size()])

func idle():
	attacking = false
	running = false
	state_machine.travel("idle")
	await get_tree().create_timer(randi_range(1,3)).timeout

func _attack_start():
	_special_attack_active()

func _attack_end():
	if not special_attack_active:
		attacking = false
		if target:
			change_facing_direction()
		idle()
		

func _special_attack_active():
	var chance = randf()
	special_attack_active = chance < 0.5
	animation_tree["parameters/conditions/special_attack_at_end"] = special_attack_active

func _special_attack_end():
	special_attack_active = false
	attacking = false
	if target:
		change_facing_direction()
	idle()

func change_facing_direction():
	var target_dif_x = target.position.x - global_position.x
	var facing_right = target_dif_x <= 0
	sprite_2d.flip_h = facing_right
	%"Attack Area".scale.x = -1 if facing_right else 1

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		target = body
		%PlayerCollision.set_deferred("disabled",true)
		%CanvasGroup.show()
		
func _damage_anim_end():
	taking_damage = false
	idle()
	
func take_damage():
	if not attacking or not special_attack_active:
		change_facing_direction()
		taking_damage = true
		health -= 20
		velocity = Vector2.ZERO  # Durdur
		state_machine.travel("damage")
