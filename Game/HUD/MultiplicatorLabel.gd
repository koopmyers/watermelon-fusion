extends Label


export var FONT_COLORS := {
#	2: Color("#b3e5fc"),
#	3: Color("#0999d8"),
	2: Color("#f79ff9"),
	3: Color("#fd89c5"),
	4: Color("#fd85ae"),
	5: Color("#fec341"),
	6: Color("#f99831"),
	7: Color("#f15638"),
	8: Color("#f14938"),
}


var tween := Tween.new()


func _ready():
	add_child(tween)
	set_value(0)


func set_value(p_value: int):
#	print("Multiplicator set value ", p_value)
	
	if p_value < 2:
		text = ""
		rect_scale = Vector2.ZERO
		return
	
	
	text = "x" + str(p_value)
	
	add_color_override("font_color", FONT_COLORS.get(p_value, Color.white))
#	add_color_override("font_color_shadow", shadow_color)
	
	tween.interpolate_property(self, "rect_scale", Vector2.ZERO,  Vector2.ONE,
		0.1, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")


func _on_Game_multiplicator_updated(multiplicator):
	set_value(multiplicator)
