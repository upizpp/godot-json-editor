tool
extends ScrollContainer


export(PoolStringArray) var keywords


onready var editor = $"../../JsonTextEdit"
onready var labels = $LabelsVBoxContainer


var index = 0 setget set_index
var label_count = 0
var word = ""
var focus = false


func _ready():
	$"../AutoCompleteTimer".start()


func _input(event):
	if not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed:
		match (event.scancode):
			KEY_UP:
				focus = true
				set_index(index - 1)
				editor.release_focus()
			KEY_DOWN:
				focus = true
				set_index(index + 1)
				editor.release_focus()
			KEY_TAB, KEY_ENTER:
				var keyword = labels.get_child(index).text
				var line : String = editor.get_line(editor.cursor_get_line())
				var begini : int = editor.cursor_get_column() - 1
				var endi : int = line.find(" ", editor.cursor_get_column() - 1)
				while (begini > 0):
					if line[begini] == " ":
						break
					begini -= 1
				if endi == -1:
					endi = line.length() - 1
				var begin = line.substr(0, begini + 1) if begini > 0 else ""
				var end = line.substr(endi + 1, -1)
				line = begin + keyword + end
				editor.set_line(editor.cursor_get_line(), line)
				reset_label()
				hide()
				focus = false
				yield(get_tree(), "idle_frame")
				editor.grab_focus()
				editor.cursor_set_column(editor.cursor_get_column() + keyword.length() - word.length())
			KEY_LEFT, KEY_RIGHT, KEY_ESCAPE:
				hide()
				focus = false
				editor.grab_focus()


# ----- Signals -----
func _on_AutoCompleteTimer_timeout():
	if focus:
		show()
		return
	word = editor.get_word(editor.cursor_get_column() - 1)
	if word == null or word.empty():
		hide()
		focus = false
		return
	var flag = false
	for keyword in keywords:
		if word in keyword and word != keyword:
			flag = true
			break
	if flag and editor.has_focus():
		show()
		reset_label()
		init_label(word)
		rect_position = editor.get_current_pos(word)
	else:
		hide()
		focus = false


# ----- Funcitons -----
func set_index(value):
	index = clamp(value, 0, label_count - 1)
	for label in labels.get_children():
		label.set("custom_styles/normal", null)
	labels.get_child(index).set("custom_styles/normal", $"../..".get_theme().get("ScrollContainer/styles/focus"))


func init_label(message : String) -> void:
	label_count = 0
	for keyword in keywords:
		if message in keyword:
			add_label(keyword)
			label_count += 1
	set_index(0)


func reset_label() -> void:
	for label in labels.get_children():
		label.queue_free()


func add_label(message : String) -> void:
	var label = Label.new()
	label.text = message
	labels.add_child(label)

