extends KinematicBody2D


signal armed
signal dropped

const SPEED := 700
const FRUIT_DROP_IMPULSE := 800
const ARM_DURATION := 0.5 # sec


var loaded := false
var armed := false

var drop_position_x := 0 # global
var user_dropped := false

var next_fruit: Fruit
var current_fruit: Fruit

onready var tween := $Tween
onready var timer := $Timer
onready var next_fruit_position: Vector2 = $Position2D.position
onready var collision_shape := $CollisionShape2D


func load_fruit(fruit):
	
	fruit.global_position.x = 0
	fruit.global_position.y = global_position.y + next_fruit_position.y
	
	next_fruit = fruit
	loaded = true
	
	yield(next_fruit.grow(), "completed")
	if not armed:
		arm()


func unload():
	loaded = false
	armed = false
	
	user_dropped = false
	current_fruit = null
	next_fruit = null


func arm():
	if not loaded:
		return
	
	drop_position_x = 0
	position.x = 0
	
	var fruit = next_fruit
	
	loaded = false
	next_fruit = null
	
	tween.interpolate_property(fruit, "global_position", fruit.global_position,  global_position,
		ARM_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	if not is_instance_valid(fruit): # fruit has been freed while tweening
		return
	
	armed = true
	current_fruit = fruit
	collision_shape.shape = current_fruit.get_collision_shape()
	emit_signal("armed")



func _on_UserInputsController_fruit_moved(_pos_x):
	pass
#	if null == current_fruit:
#		return
#	drop_position_x = pos_x


func _physics_process(delta):
	if not armed:
		return
		
	var target := Vector2(drop_position_x, global_position.y)
	
	if SPEED*0.1 < position.distance_squared_to(target):
		var movement := position.direction_to(target)* SPEED
		var collision := move_and_collide(movement * delta)
		
		if is_instance_valid(current_fruit):
			current_fruit.global_position = global_position
		
		if collision:
			drop()
	
	elif user_dropped:
		drop()


func _on_UserInputsController_fruit_dropped(pos_x):
	if not armed:
		return
	
	if user_dropped:
		return
	
	drop_position_x = pos_x
	user_dropped = true



func drop():
	if not armed:
		return
	
	if is_instance_valid(current_fruit):
		current_fruit.fall(FRUIT_DROP_IMPULSE)
		current_fruit = null
	
	armed = false
	user_dropped = false
	drop_position_x = 0
	
	if not armed and loaded:
		arm()
	
	emit_signal("dropped")

