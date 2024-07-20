extends Node
@onready var coin_counter = %coin_counter

var score = 0

func add_point():
	score +=1
	coin_counter.text = str(score)
