extends Label




func _ready():
	text = "0"


func _on_Game_score_updated(score: int):
	text = str(score)
