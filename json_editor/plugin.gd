tool
extends EditorPlugin

const TextEditor = preload("res://addons/json_editor/text_editor/EditorControl.tscn")
var text_editor : Control


func _enter_tree():
	text_editor = TextEditor.instance()
	get_editor_interface().get_editor_viewport().add_child(text_editor)
	make_visible(false)


func _exit_tree():
	if text_editor:
		text_editor.save_data()
		text_editor.queue_free()


func _ready():
	var dialog = EditorFileDialog.new()
	dialog.add_filter("*.json")
	dialog.connect("file_selected", text_editor, "_on_file_dialog_selected")
	text_editor.add_child(dialog)
	text_editor.init(dialog)


func make_visible(visible : bool):
	if text_editor:
		text_editor.visible = visible


func get_plugin_name():
	return "Json Editor"


func get_plugin_icon():
	return preload("icon_empty.png")


func has_main_screen():
	return true


func edit(object):
	if object is  JsonScript:
		text_editor.open(object.resource_path)
		make_visible(true)
		emit_signal("main_screen_changed", "Json Editor")


func handles(object: Object) -> bool:
	return object is JsonScript

