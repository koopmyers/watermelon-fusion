extends Node2D


signal menu_pressed

signal score_updated(score)
signal multiplicator_updated(multiplicator)
signal next_fruit_updated(type)

signal ended


const TOP_SCREEN_MARIN := 350 #px
const BOTTOM_SCREEN_MARGIN := 50 #px
const CLAW_BOX_MARING := 105


const CLAW_FRUITS := [Fruit.Type.CHERRY, Fruit.Type.STRAWBERRY, Fruit.Type.GRAPES, Fruit.Type.LEMON, Fruit.Type.ORANGE]
const CLAW_START_SEQUENCE := [Fruit.Type.CHERRY, Fruit.Type.CHERRY, Fruit.Type.STRAWBERRY, Fruit.Type.GRAPES]
const FRUIT_FALL_FUSION_IMPULSE := 500

const MULTIPLICATOR_MAX := 8

export(PackedScene) var FruitScene

var claw_index := 0 # total amout of fruits loaded
var fruits_unlocked = [] # fruit autorized to be loaded, fruit of the claw list can only be loaded if already seen in the current game

var next_fruit_type: int setget set_next_fruit_type

var score := 0 setget set_score
var multiplicator := 0 setget set_multiplicator


onready var foreground := $Foreground #HUD

onready var multiplicator_timer := $MultiplicatorTimer
onready var pop_timer := $PopTimer
onready var claw := $Claw
onready var box := $Box
onready var fruits := $Fruits
onready var camera := $Camera2D


func _ready():
	pass


func _on_MenuButton_pressed():
	emit_signal("menu_pressed")


func set_area(p_view_rect: Rect2, p_safe_rect: Rect2):
	
	var margin_top := abs(p_view_rect.position.y - p_safe_rect.position.y)
	var margin_bottom := abs(p_view_rect.size.y - p_safe_rect.size.y) - margin_top
	
	claw.position.y = -(p_safe_rect.size.y - TOP_SCREEN_MARIN + CLAW_BOX_MARING - margin_top)
	
	var box_area := p_safe_rect.size
	box_area.y -= TOP_SCREEN_MARIN + margin_top
	box.set_size(box_area)
	
	camera.position.y = -(p_view_rect.size.y*0.5) + margin_bottom + BOTTOM_SCREEN_MARGIN


func set_score(p_score: int):
	score = p_score
	emit_signal("score_updated", score)


func set_multiplicator(p_multiplicator: int):
	multiplicator = p_multiplicator
	emit_signal("multiplicator_updated", multiplicator)


func set_next_fruit_type(p_type: int):
	next_fruit_type = p_type
	emit_signal("next_fruit_updated", next_fruit_type)


func unlock_fruit(type: int):
	if not type in CLAW_FRUITS:
		return
	
	if type in fruits_unlocked:
		return
	
	fruits_unlocked.append(type)


func roll_next_fruit() -> int:
	var type = Fruit.Type.CHERRY
	if claw_index < len(CLAW_START_SEQUENCE):
		type = CLAW_START_SEQUENCE[claw_index] # in this order
		claw_index += 1 
		
	else:
		var rn := randi() % len(fruits_unlocked)
		type =  fruits_unlocked[rn]
	
	return type


func load_claw():
	
	var fruit: Fruit = FruitScene.instance()
	fruits.add_child(fruit)
	fruit.type = next_fruit_type
	fruit.connect("fusionned", self, "_on_fruit_fusionned", [fruit])
	
	claw.load_fruit(fruit)
	
	unlock_fruit(fruit.type)
	self.next_fruit_type = roll_next_fruit()
	

func _on_Claw_armed():
	load_claw()


func _on_fruit_fusionned(fruit_a: Fruit, fruit_b: Fruit):
	if Fruit.Type.WATERMELON == fruit_a.type:
		return
	
	self.multiplicator = min(MULTIPLICATOR_MAX, multiplicator + 1)
	self.score += (fruit_a.points + fruit_b.points) * multiplicator
	multiplicator_timer.start()
	
	var pos: Vector2 = (fruit_a.global_position + fruit_b.global_position) * 0.5 # center betwen two points
	fruit_a.delete(pos)
	fruit_b.delete(pos)
	
	call_deferred("new_fruit_fusion", Fruit.get_evolution_type_of(fruit_a.type), pos)


func new_fruit_fusion(p_type, pos):
	var new_fruit: Fruit = FruitScene.instance()
	fruits.add_child(new_fruit)
	new_fruit.type = p_type
	new_fruit.connect("fusionned", self, "_on_fruit_fusionned", [new_fruit])
	
	unlock_fruit(new_fruit.type)
	
	new_fruit.global_position = pos
	new_fruit.fall(FRUIT_FALL_FUSION_IMPULSE)
	yield(new_fruit.grow(true), "completed")


func _on_MultiplicatorTimer_timeout():
	self.multiplicator = 0


func _on_Box_limit_reached():
	end()


func start():
	self.next_fruit_type = roll_next_fruit()
	load_claw()



func end():
	
	claw.unload()
	
	var fruits_sorted := fruits.get_children()
	fruits_sorted.sort_custom(self, "_comp_fruit_heigth")
	
	var max_time := 0.35
	var min_time := 0.1
	var fruits_amount = len(fruits_sorted)
	
	var i := 0
	for fruit in fruits_sorted:
		if not is_instance_valid(fruit):
			continue
		
		self.score += fruit.points
		fruit.pop()
	
		var time = lerp(max_time, min_time, float(i/5.0))
		i += 1
		
		pop_timer.start(time)
		yield(pop_timer, "timeout")
	
	
	pop_timer.start(1.0)
	yield(pop_timer, "timeout")
	emit_signal("ended")


func _comp_fruit_heigth(fruit_a: Fruit, fruit_b: Fruit):
	if fruit_a.in_danger == fruit_b.in_danger:
		return fruit_a.global_position.y < fruit_b.global_position.y
	
	return fruit_a.in_danger



func reset():
	self.score = 0
	
	claw_index = 0
	fruits_unlocked.clear()
	claw.unload()
	
	for fruit in fruits.get_children():
		fruit.delete()
