extends Node

# this script can be accessed across all the scenes
# currently being used like RAM in a computer: short term memory storage for the player's stats

# has to be accessed by mutliple scenes globally
const enemy_names = ["Slime", "Dionysus", "Golem"]

var player_name = ""
var start_time = 0
var enemies_slain_stage_one = 0
var enemies_slain_stage_two = 0
var enemies_slain_stage_three = 0
var end_time = 0
var final_score = 0

var health = 100

func _ready():
	pass
