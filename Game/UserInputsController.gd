extends Node2D


signal fruit_moved(pos)
signal fruit_dropped(pos)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _unhandled_input(event):
	
	event = make_input_local(event)
	
	if event is InputEventScreenTouch:
		
		if event.is_pressed():
			emit_signal("fruit_dropped", event.position.x)
		
#		else:
#			emit_signal("fruit_dropped", event.position.x)
	
	if event is InputEventScreenDrag:
		
		emit_signal("fruit_moved", event.position.x)
	
	
	if OS.is_debug_build() and event.is_action_pressed("ui_accept"):
		emit_signal("fruit_dropped", get_local_mouse_position().x)
