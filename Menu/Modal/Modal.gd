extends Container
class_name Modal


signal closed
signal opened


const OPEN_ANIMATION_TIME = 0.3
const CLOSE_ANIMATION_TIME = 0.2
const TRANSPARENT_MODULATE = Color(1, 1, 1, 0)
const OPAQUE_MODULATE = Color(1, 1, 1, 1)


#export(NodePath) var title_label_NodePath
#export(NodePath) var topbar_control_NodePath
export(NodePath) var content_container_NodePath
#export(NodePath) var back_button_NodePath
export(NodePath) var background_NodePath



var _open := false
var tween := Tween.new()


onready var viewport := get_viewport()
onready var children = get_children()
#onready var _modal = $_Modal

#onready var title_label: Label = get_node(title_label_NodePath)
#onready var topbar_control: Control = get_node(topbar_control_NodePath)
onready var content_container: Container = get_node(content_container_NodePath)
#onready var back_button: Button = get_node(back_button_NodePath)
onready var background: ColorRect = get_node(background_NodePath)



func _init():
	pass


func _ready():
#	assert(title_label)
#	assert(topbar_control)
	assert(content_container)
#	assert(back_button)
	assert(background)
	
	
	add_child(tween)
#	add_child(_modal)
#	move_child(_modal, 0)
	
#	for node in children:
#		remove_child(node)
#		_modal.content_container.add_child(node)
	
#	viewport.connect("size_changed", self, "resize")
#	_modal.back_button.connect("pressed", self, "close")
	background.connect("gui_input", self, "_on_back_ground_gui_input")
	
#	_modal.title_label.text = title
#	_modal.topbar_control.visible = topbar
	
#	resize()
	hide()
	modulate = TRANSPARENT_MODULATE


#func resize():
#	var rect = Rect2(-rect_global_position, viewport.size)
#	fit_child_in_rect(_modal, rect)



func _on_back_ground_gui_input(event):
	if event is InputEventMouse and event.is_pressed():
		close()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		close()


func open():
	if _open:
		return
	
	_open = true
	emit_signal("opened")
	
	
	tween.stop_all()
	tween.remove_all()
	tween.interpolate_property(
		self, "modulate",
		modulate, OPAQUE_MODULATE,
		OPEN_ANIMATION_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	show()
	tween.start()
	
	yield(tween, "tween_all_completed")


func close():
	if not _open:
		return
	
	_open = false
	
	tween.stop_all()
	tween.remove_all()
	tween.interpolate_property(
		self, "modulate",
		modulate, TRANSPARENT_MODULATE,
		OPEN_ANIMATION_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_all_completed")
	hide()
	emit_signal("closed")


#func set_title(p_title):
#	title = p_title
#
#	if not _modal or not _modal.title_label.text:
#		return
#
#	_modal.title_label.text = title


#func set_topbar(p_topbar):
#	topbar = p_topbar
#
#	if not _modal or not _modal.topbar_control:
#		return
