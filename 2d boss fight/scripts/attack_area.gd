extends Area2D

@export var attack_value: int = 10
@onready var attack_area = %"Attack Area"


func _ready():
	attack_area.get_node("CollisionShape2D").disabled = true
	
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
