extends KinematicBody2D


const SPEED = 85
const GRAVITY = 30
const JUMP_POWER = -350
const FLOOR = Vector2(0,-1)

const SPEAR = preload("res://Spear.tscn")

var velocity = Vector2()

var on_ground = false

# only changes animation after the attack animation is done
var is_attacking = false
var previous_animation = "idle"

# if direction changes while attack animation is still playing, the direction is
# stored in the "direction" variable, and then will change once attack is finished
var direction = "left"

# this is for the passthrough function of platforms
func input_process(actor, event):
	if event.is_action_pressed(actor.jump):
		if actor.has_node("pass_through") and Input.is_action_pressed("ui_s"):
			actor.set_collision_mask_bit(1,false)
		else:
			actor.jump

func _physics_process(delta):

	# running left and right animations and mechanics
	# will not flip direction of sprite until the attack animation is done
	if Input.is_action_pressed("ui_d"):
		velocity.x = SPEED
		$Melee.position.x = 12
		direction = "left"
		if is_attacking == false:
			$AnimatedSprite.play("run")
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1
	elif Input.is_action_pressed("ui_a"):
		velocity.x = -SPEED
		$Melee.position.x = -12
		direction = "right"
		if is_attacking == false:
			$AnimatedSprite.play("run")
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	else:
		velocity.x = 0
		if on_ground == true:
			if is_attacking == false:
				$AnimatedSprite.play("idle")
	if is_attacking == false:
		if direction == "left":
			$AnimatedSprite.flip_h = false
		if direction == "right":
			$AnimatedSprite.flip_h = true
		
	# jump mechanics
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_w"): #ui_accept is the space bar or enter bar
		if on_ground == true:
			velocity.y = JUMP_POWER
			on_ground = false
	
	# player can only attack after shooting animation completes
	if Input.is_action_just_pressed("ui_t"):
		if $AnimatedSprite.animation != "sword":
			is_attacking = true
			$AnimatedSprite.play("spear")
			var spear = SPEAR.instance()
			if sign($Position2D.position.x) == 1:
				spear.set_fireball_direction(1)
			else:
				spear.set_fireball_direction(-1)
			get_parent().add_child(spear)
			spear.position = $Position2D.global_position
	if Input.is_action_just_pressed("ui_g"):
		if $AnimatedSprite.animation != "spear":
			is_attacking = true
			if direction == "left":
				$AnimatedSprite.offset.x = 14
			elif direction == "right":
				$AnimatedSprite.offset.x = -14

			for bob in $Melee.get_overlapping_bodies():
				if bob.name.find("Slime") != -1:
					bob.dead()

		$AnimatedSprite.play("sword")

	
	velocity.y = velocity.y + GRAVITY
	
	# jumping/falling animation
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
		if velocity.y <0:
			if is_attacking == false:
				$AnimatedSprite.play("jump")
		else:
			if is_attacking == false:
				$AnimatedSprite.play("fall")
	
	velocity = move_and_slide(velocity, FLOOR)
	
	previous_animation = $AnimatedSprite.animation
	
	
# pass through platform function tutorial: https://www.youtube.com/watch?v=T704Zrlye2k&ab_channel=Pigdev


func _on_AnimatedSprite_animation_finished():
	if previous_animation == "sword":
		# changes to idle first because if not, the character will offset back to 0 without
		# finishing changing its animation, creating a glitching effect
		$AnimatedSprite.play("idle")
		$AnimatedSprite.offset.x = 0
	if previous_animation == "spear" or previous_animation == "sword":
		is_attacking = false
