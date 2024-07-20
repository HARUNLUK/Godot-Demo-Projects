extends Node

var bosses = []

# Bossları eklemek için bir fonksiyon
func add_boss(boss):
	bosses.append(boss)

# Bossları kaldırmak için bir fonksiyon
func remove_boss(boss):
	bosses.erase(boss)

# Bütün bossları almak için bir fonksiyon
func get_bosses():
	return bosses
	
func get_boss_by_name(name: String):
	for boss in bosses:
		if boss.name == name:
			return boss
	return null
