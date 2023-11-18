extends Control



static func control_to_window_safe_area(control: Control):
	if control.get_viewport() != control.get_tree().root:
		return
	
	var window_to_root = Transform2D.IDENTITY.scaled(control.get_tree().root.size / OS.window_size)
	var safe_area_root = window_to_root.xform(OS.get_window_safe_area())
	
	var parent_to_root = control.get_viewport_transform() * control.get_global_transform() * control.get_transform().affine_inverse()
	var root_to_parent = parent_to_root.affine_inverse()
	
	var safe_area_relative_to_parent = root_to_parent.xform(safe_area_root)
	
	
	control.set_deferred("rect_position", safe_area_relative_to_parent.position)
	control.set_deferred("rect_size", safe_area_relative_to_parent.size)



func _ready():
	control_to_window_safe_area(self)
