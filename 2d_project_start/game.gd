extends Node2D


	
func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	var boss = preload("res://boss.tscn").instantiate()
	var bigboss = preload("res://big_boss.tscn").instantiate()
	
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	var pos =  randi_range(0,50)
	if pos < 5:
		if pos <2:
			add_child(bigboss)
		else:
			add_child(boss)
	else:
		add_child(new_mob)
	


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true
