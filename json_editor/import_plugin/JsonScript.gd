tool
extends Resource
class_name JsonScript


var data : String


func get_as_text() -> String:
	var file = File.new()
	file.open(self.resource_path, File.READ)
	return file.get_as_text()


func set_as_text(text : String) -> void:
	var file = File.new()
	file.open(self.resource_path, File.WRITE)
	file.store_string(text)
	emit_changed()


func get_data():
	return parse_json(get_as_text())


func set_data(data) -> void:
	set_as_text(JSON.print(data, "\t"))
