extends StaticBody2D


signal limit_reached


const ANIM_NAME := "in_limit"

onready var animation_player := $AnimationPlayer

onready var limit_area: Area2D = $Limit
onready var wall_left := $WallLeft
onready var wall_right := $WallRight


func set_size(p_size: Vector2):
	
	limit_area.position.y = -abs(p_size.y)
	var half_width := float(abs(p_size.x) *0.5)
	wall_left.position.x = - (half_width + wall_left.shape.extents.x)
	wall_right.position.x = (half_width + wall_right.shape.extents.x)


func _on_Limit_body_entered(body):
	pass # Replace with function body.


func _on_Limit_body_exited(body):
	if not body is Fruit:
#		print("Body out, but not Fruit")
		return
	
	body.in_danger = false



func _physics_process(delta):
	
	var bodies := limit_area.get_overlapping_bodies()
	
	if not bodies:
		animation_player.stop()
	
	for body in bodies:
		if not body is Fruit:
#			print("Body in, but not Fruit")
			continue
		
		if body.invincible:
#			print("Body in, but invicible")
			continue
		
		body.in_danger = true
		
		if not animation_player.is_playing():
			animation_player.play(ANIM_NAME)


func _on_AnimationPlayer_animation_finished(anim_name):
	if ANIM_NAME != anim_name:
		return
	
	emit_signal("limit_reached")
