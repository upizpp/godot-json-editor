tool
extends Control


onready var title = $Options/Title
onready var editor = $JsonTextEdit
onready var file_menu = $Options/FileMenu
onready var edit_menu = $Options/EditMenu
onready var current_display = $Options/CurrentDisplay
onready var tabs = $Tabs


var file_dialog


var ctrl_pressed : bool = false
var current : bool = false setget set_current
var select_id : int = 0
var files = []


func load_data():
	var data = File.new()
	data.open("res://addons/json_editor/data.json", File.READ)
	var datas = parse_json(data.get_as_text())
	var file = File.new()
	if datas:
		if file.open(datas[0], File.READ) == OK:
			editor.text = file.get_as_text()
		for i in datas:
			tabs.add_tab(i.get_file())
		title.text = datas[0]
	files = datas
	file.close()
	data.close()


func save_data():
	if title and not title.text.empty():
		save(title.text)
	var data = File.new()
	data.open("res://addons/json_editor/data.json", File.WRITE)
	data.store_string(JSON.print(files, "\t"))
	data.close()


func init(dialog):
	change_font_size(24)
	file_dialog = dialog
	file_menu.get_popup().connect("id_pressed", self, "_on_file_menu_pressed")
	edit_menu.get_popup().connect("id_pressed", self, "_on_edit_menu_pressed")
	load_data()


func save(path : String):
	if path.empty():
		return
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(editor.text)
	set_current(false)
	title.text = path


func open(path : String):
	if files.has(path):
		return
	if path.empty():
		return
	files.push_back(path)
	tabs.add_tab(path.get_file())
	var file = File.new()
	file.open(path, File.READ)
	editor.text = file.get_as_text()
	editor.clear_undo_history()
	set_current(false)
	title.text = path


func new(path : String):
	editor.text = ""
	tabs.current_tab = tabs.get_tab_count() - 1
	title.text = path
	tabs.add_tab(path.get_file())
	files.push_back(path)
	set_current(false)


func _on_file_dialog_selected(path : String):
	match select_id:
		0:
			new(path)
		1, 2:
			save(path)
		3:
			open(path)
			tabs.current_tab = tabs.get_tab_count() - 1


func change_font_size(value : int):
	var theme = editor.get("theme")
	var font = theme.get("default_font")
	font.set("size", value if value > 0 else 1)
	theme.set("default_font", font)
	editor.set("theme", theme)


func get_font_size() -> int:
	return editor.get("theme").get("default_font").get("size")


func _input(event):
	if event.as_text() == "Control":
		ctrl_pressed = event.pressed


func _gui_input(event):
	if event is InputEventMouseButton and ctrl_pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			change_font_size(get_font_size() + 2)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			change_font_size(get_font_size() - 2)
	if event is InputEventKey:
		if event.pressed:
			match event.as_text():
				"Control+N":
					file_dialog.popup_centered(Vector2(960, 640))
					file_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
					select_id = 0
				"Control+S":
					if title.text.empty():
						file_dialog.popup_centered(Vector2(960, 640))
					else:
						save(title.text)
					file_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
					select_id = 1
				"Control+Shift+S":
					file_dialog.popup_centered(Vector2(960, 640))
					file_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
					select_id = 2
				"Control+O":
					file_dialog.popup_centered(Vector2(960, 640))
					file_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
					select_id = 2
				"Control+E":
					check_error()
					select_id = 3


func _on_file_menu_pressed(id):
	match id:
		0:
			file_dialog.popup_centered(Vector2(960, 640))
			file_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
		1:
			if title.text.empty():
				file_dialog.popup_centered(Vector2(960, 640))
			else:
				save(title.text)
			file_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
		2:
			file_dialog.popup_centered(Vector2(960, 640))
			file_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
		3:
			file_dialog.popup_centered(Vector2(960, 640))
			file_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
		4:
			check_error()
	select_id = id


func _on_edit_menu_pressed(id : int):
	match id:
		0:
			editor.undo()
		1:
			editor.redo()
		3:
			editor.copy()
		4:
			editor.cut()
		5:
			editor.paste()
		7:
			editor.select_all()
		8:
			editor.text = ''


func _on_EditMenu_about_to_show():
	edit_menu.get_popup().set_item_disabled(0, not editor.has_undo())
	edit_menu.get_popup().set_item_disabled(1, not editor.has_redo())
	edit_menu.get_popup().set_item_disabled(7, editor.text.empty())
	edit_menu.get_popup().set_item_disabled(8, editor.text.empty())


func _on_JsonTextEdit_text_changed():
	set_current(true)


func set_current(value):
	current = value
	current_display.visible = current


func check_error():
	if not editor.text.empty():
		var data = parse_json(editor.text)
		if data == null:
			print("Parse Faild!")
			editor.theme.set("TextEdit/colors/background_color", Color(0.4, 0.3, 0.3))
			editor.theme.set("TextEdit/colors/current_line_color", Color(0.4, 0.3, 0.3))
		else:
			print("Parse Successed!")
			editor.theme.set("TextEdit/colors/background_color", Color(0.12549, 0.145098, 0.192157))
			editor.theme.set("TextEdit/colors/current_line_color", Color(0.188235, 0.203922, 0.25098))		


func _on_Tabs_tab_changed(tab):
	save(title.text)
	if not files.empty():
		var file = File.new()
		file.open(files[tab], File.READ)
		title.text = files[tab]
		editor.text = file.get_as_text()
	else:
		editor.text = " "
		title.text = " "
	editor.clear_undo_history()


func _on_Tabs_tab_close(tab):
	files.remove(tab)
	tabs.remove_tab(tab)
	_on_Tabs_tab_changed(tab - 1)
