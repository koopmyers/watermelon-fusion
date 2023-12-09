extends Node



const STORAGE_PATH := "user://store.ini"

const save_section := "save"
const best_score_key := "best_score"

onready var start_menu
onready var game := $Game
onready var menu := $Menus/Menu



var best_score: int = 0


var config_file := ConfigFile.new()
#var config_file_path: String = ProjectSettings.get_setting(STORAGE_PATH)


func _ready():
	best_score = load_best_score()
	
	var window_to_root := Transform2D.IDENTITY.scaled(game.get_tree().root.size / OS.window_size)
	var safe_area_root: Rect2 = window_to_root.xform(OS.get_window_safe_area())
	
	var parent_to_root = game.get_viewport_transform() * game.get_global_transform() * game.get_transform().affine_inverse()
	var root_to_parent = parent_to_root.affine_inverse()
	
	var viewport_relative_to_parent = root_to_parent.xform(Rect2(Vector2.ZERO, get_viewport().size))
	var safe_area_relative_to_parent = root_to_parent.xform(safe_area_root)
	
	game.set_area(viewport_relative_to_parent, safe_area_relative_to_parent)
	game.start()


func load_best_score() -> int:
	if  config_file.load(STORAGE_PATH) != OK: # If the file didn't load, ignore it.
		print("Coundn't load {file}".format({"file": STORAGE_PATH}))
		return 0
	
	return config_file.get_value(save_section, best_score_key, 0)


func save_best_score(p_best_score: int):
	config_file.set_value(save_section, best_score_key, p_best_score)
	
	if  config_file.save(STORAGE_PATH) != OK:
		print("Coundn't save {file}".format({"file": STORAGE_PATH}))
		return



func exit_app():
	get_tree().quit()



func _on_Game_menu_pressed():
	menu.open_in_game(best_score)


func _on_Game_ended():
	if best_score < game.score:
		best_score = game.score
		save_best_score(best_score)
	
	menu.open_end_game(best_score, game.score)


func _on_GameMenu_replay_pressed():
	if not is_instance_valid(game):
		return
	
	game.reset()
	game.start()
	
	menu.close()
