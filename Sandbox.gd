extends Node2D


onready var fruits := $Fruits.get_children()



func _ready():
	call_deferred("start")


func start():
	for fruit in fruits:
		print(fruit.type)
		
		fruit.type = fruit.type
		fruit.fall()
		fruit.grow()
